require "test_helper"

module Comments
  class TreeQueryTest < ActiveSupport::TestCase
    test "returns root comments with children counts" do
      root = create(:comment)
      create(:comment, parent: root)
      page = Comments::TreeQuery.call
      assert_equal 1, page.total
      node = page.comments.first
      assert_equal root.id, node[:id]
      assert_equal 1, node[:children_count]
    end

    test "returns the direct children of a parent" do
      root = create(:comment)
      child = create(:comment, parent: root)
      page = Comments::TreeQuery.call(parent_id: root.id)
      assert_equal [ child.id ], page.comments.map { |c| c[:id] }
    end

    test "paginates newest roots first" do
      old = create(:comment, created_at: 3.days.ago)
      mid = create(:comment, created_at: 2.days.ago)
      new = create(:comment, created_at: 1.day.ago)

      page = Comments::TreeQuery.call(per: 2, page: 1)
      assert_equal [ new.id, mid.id ], page.comments.map { |c| c[:id] }
      assert page.has_more

      page2 = Comments::TreeQuery.call(per: 2, page: 2)
      assert_equal [ old.id ], page2.comments.map { |c| c[:id] }
    end
  end
end
