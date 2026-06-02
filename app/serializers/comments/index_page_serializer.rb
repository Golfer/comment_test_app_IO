module Comments
  module IndexPageSerializer
    module_function

    def call(page, params)
      if page.search?
        SearchResultSerializer.call(page.search_result)
      else
        TreePageSerializer.call(
          TreeQuery.call(
            parent_id: params[:parent_id],
            page: params[:page],
            per: params[:per]
          )
        )
      end
    end
  end
end
