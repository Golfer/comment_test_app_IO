module Comments
  class TreeQuery < ApplicationQuery
    DEFAULT_PER = 25
    MAX_PER = 100

    def initialize(parent_id: nil, page: 1, per: DEFAULT_PER)
      @parent_id = parent_id
      @page = Pagination.page(page)
      @per = Pagination.per(per, max: MAX_PER)
    end

    def call
      scope = base_scope.order(created_at: :desc)
      total = scope.count
      records = scope.offset((@page - 1) * @per).limit(@per).includes(:user)
      children_counts = ThreadCountsQuery.direct_children(records)

      TreePage.new(
        parent_id: @parent_id,
        page: @page,
        per: @per,
        total: total,
        has_more: @page * @per < total,
        comments: records.map { |comment| comment.as_json_node(children_count: children_counts[comment.child_ancestry] || 0) }
      )
    end

    private

    def base_scope
      if @parent_id.present?
        Comment.find(@parent_id).children
      else
        Comment.roots
      end
    end
  end
end
