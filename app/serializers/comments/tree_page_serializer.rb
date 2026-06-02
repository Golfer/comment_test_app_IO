module Comments
  module TreePageSerializer
    module_function

    def call(page)
      {
        parent_id: page.parent_id,
        page: page.page,
        per: page.per,
        total: page.total,
        has_more: page.has_more,
        comments: page.comments
      }
    end
  end
end
