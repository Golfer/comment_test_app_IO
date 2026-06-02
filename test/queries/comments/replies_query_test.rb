require "test_helper"

module Comments
  class RepliesQueryTest < ActiveSupport::TestCase
    test "returns a thread with reply counts" do
      root = create(:comment, body: "root")
      child = create(:comment, parent: root, body: "child")
      create(:comment, parent: child, body: "grandchild")

      result = RepliesQuery.call(parent_id: root.id)
      assert_equal root, result.parent
      assert_equal 2, result.replies.size
      assert_equal 1, result.thread_reply_counts.fetch(child.id)
    end
  end
end
