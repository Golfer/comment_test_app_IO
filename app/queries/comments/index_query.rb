module Comments
  # Prepares everything the comments index needs (HTML + JSON).
  class IndexQuery < ApplicationQuery
    FEED_LIMIT = 100

    def initialize(params)
      @params = params
    end

    def call
      if @params[:q].present?
        build_search_page
      else
        build_feed_page
      end
    end

    private

    def build_search_page
      IndexPage.new(
        search_result: SearchQuery.call(
          query: @params[:q],
          page: @params.fetch(:page, 1),
          per: @params.fetch(:per, SearchQuery::DEFAULT_PER),
          include_comments: true
        ),
        roots: [],
        thread_reply_counts: {},
        open_thread_id: 0,
        highlight_comment_id: 0,
        next_page: nil
      )
    end

    def build_feed_page
      page_number = [ @params[:page].to_i, 1 ].max
      offset = (page_number - 1) * FEED_LIMIT
      records = Comment.recent_roots.includes(:user).offset(offset).limit(FEED_LIMIT + 1).to_a
      roots = records.first(FEED_LIMIT)
      open_thread_id = @params[:thread].presence&.to_i || 0
      roots = ensure_open_thread_root!(roots, open_thread_id, page_number)
      next_page = records.size > FEED_LIMIT ? page_number + 1 : nil

      IndexPage.new(
        search_result: nil,
        roots: roots,
        thread_reply_counts: ThreadCountsQuery.call(roots),
        open_thread_id: open_thread_id,
        highlight_comment_id: @params[:highlight].presence&.to_i || 0,
        next_page: next_page
      )
    end

    def ensure_open_thread_root!(roots, open_thread_id, page_number)
      return roots if open_thread_id.zero? || page_number > 1
      return roots if roots.any? { |comment| comment.id == open_thread_id }

      open_root = Comment.includes(:user).find_by(id: open_thread_id)
      return roots unless open_root

      if roots.size >= FEED_LIMIT
        roots = roots[0...-1]
      end

      [ open_root, *roots ]
    end
  end
end
