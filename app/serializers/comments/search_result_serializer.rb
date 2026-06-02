module Comments
  module SearchResultSerializer
    module_function

    def call(result)
      {
        query: result.query,
        page: result.page,
        per: result.per,
        total: result.total,
        next_page: result.next_page,
        hits: result.hits.map { |hit| call_hit(hit) }
      }
    end

    def call_hit(hit)
      {
        id: hit.id,
        author_name: hit.author_name,
        body: hit.body,
        highlighted_body: hit.highlighted_body,
        source: hit.source,
        created_at: hit.created_at,
        root_id: hit.root_id
      }.compact
    end
  end
end
