module Comments
  class SearchQuery < ApplicationQuery
    DEFAULT_PER = 20
    MAX_PER = 50

    def initialize(query:, page: 1, per: DEFAULT_PER, include_comments: false)
      @query = query.to_s.strip
      @page = Pagination.page(page)
      @per = Pagination.per(per, max: MAX_PER)
      @include_comments = include_comments
    end

    def call
      return empty_result if @query.blank?

      result = if meilisearch_search?
        meilisearch_call
      else
        database_call
      end

      result = attach_comments!(result) if @include_comments
      result
    end

    private

    def meilisearch_search?
      MeiliSearch::Rails.active? && ENV.fetch("MEILISEARCH_SEARCH_ENABLED", "false") == "true"
    end

    def meilisearch_call
      results = Comment.ms_raw_search(@query, {
        hits_per_page: @per,
        page: @page,
        attributes_to_highlight: [ "body" ]
      })

      build_result(
        total: results["totalHits"] || results["estimatedTotalHits"],
        hits: Array(results["hits"]).map { |hit| present_meilisearch_hit(hit) }
      )
    rescue StandardError
      database_call
    end

    def database_call
      scope = Comment.joins(:user).includes(:user)
      scope = apply_ilike_terms(scope)

      total = scope.count
      records = scope.order(created_at: :desc)
                     .offset((@page - 1) * @per)
                     .limit(@per)

      build_result(
        total: total,
        hits: records.map { |comment| present_comment(comment) }
      )
    end

    def build_result(total:, hits:, search_comments: {})
      next_page = (@page * @per) < total.to_i ? @page + 1 : nil

      SearchResult.new(
        query: @query,
        page: @page,
        per: @per,
        total: total,
        hits: hits,
        search_comments: search_comments,
        next_page: next_page
      )
    end

    def apply_ilike_terms(scope)
      search_terms.each_with_index.reduce(scope) do |relation, (term, index)|
        param = :"term_#{index}"
        relation.where(
          "comments.body ILIKE :#{param} OR users.name ILIKE :#{param}",
          param => ilike_pattern(term)
        )
      end
    end

    def search_terms
      @query.split(/\s+/).filter_map(&:presence)
    end

    def ilike_pattern(term)
      "%#{Comment.sanitize_sql_like(term)}%"
    end

    def present_meilisearch_hit(hit)
      formatted = hit["_formatted"] || {}
      highlighted = Comment.normalize_body(formatted["body"].presence || hit["body"].to_s)

      SearchHit.new(
        id: hit["id"],
        author_name: hit["author_name"],
        body: hit["body"],
        highlighted_body: highlighted,
        source: :meilisearch,
        created_at: nil,
        root_id: nil
      )
    end

    def present_comment(comment)
      SearchHit.new(
        id: comment.id,
        author_name: comment.user.display_name,
        body: comment.plain_body,
        highlighted_body: highlight_text(comment.plain_body),
        source: :database,
        created_at: comment.created_at,
        root_id: comment.root_id
      )
    end

    def highlight_text(text)
      plain = Comment.normalize_body(text)
      escaped = ERB::Util.html_escape(plain)

      search_terms.reduce(escaped) do |html, term|
        pattern = Regexp.new(Regexp.escape(term), Regexp::IGNORECASE)
        html.gsub(pattern) { |match| %(<mark class="rounded bg-yellow-100 px-0.5">#{match}</mark>) }
      end
    end

    def empty_result
      build_result(total: 0, hits: [])
    end

    def attach_comments!(result)
      ids = result.hits.map { |hit| hit.id.to_i }
      comments = Comment.where(id: ids).includes(:user).index_by(&:id)

      hits = result.hits.map do |hit|
        comment = comments[hit.id.to_i]
        next hit unless comment

        SearchHit.new(
          id: hit.id,
          author_name: hit.author_name.presence || comment.user.display_name,
          body: comment.plain_body,
          highlighted_body: highlight_text(comment.plain_body),
          source: hit.source,
          created_at: hit.created_at || comment.created_at,
          root_id: comment.root_id
        )
      end

      SearchResult.new(
        query: result.query,
        page: result.page,
        per: result.per,
        total: result.total,
        hits: hits,
        search_comments: comments,
        next_page: result.next_page
      )
    end
  end
end
