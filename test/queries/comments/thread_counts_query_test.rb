require "test_helper"

module Comments
  class ThreadCountsQueryTest < ActiveSupport::TestCase
    test "counts descendants for feed roots in one query" do
      root = create(:comment)
      create(:comment, parent: root)
      create(:comment, parent: root)

      counts = ThreadCountsQuery.call([ root ])
      assert_equal 2, counts.fetch(root.id)
    end

    test "counts replies within a loaded thread list" do
      root = create(:comment)
      child = create(:comment, parent: root)
      create(:comment, parent: child)
      replies = root.descendants.order(:ancestry_depth, :created_at)

      counts = ThreadCountsQuery.call(replies, within: true)
      assert_equal 1, counts.fetch(child.id)
    end

    test "direct_children returns immediate child counts" do
      root = create(:comment)
      create(:comment, parent: root)
      create(:comment, parent: root)

      counts = ThreadCountsQuery.direct_children([ root ])
      assert_equal 2, counts.fetch(root.child_ancestry)
    end
  end
end
