require "test_helper"

class CommentDeepLinkTest < ActiveSupport::TestCase
  test "deep_link_path opens the root thread and highlights the comment" do
    root = create(:comment, body: "root")
    reply = create(:comment, parent: root, body: "reply")

    assert_equal "/comments?highlight=#{reply.id}&thread=#{root.id}", Comment.deep_link_path(reply)
  end

  test "deep_link_path for a root comment points to itself" do
    root = create(:comment, body: "root")

    assert_equal "/comments?highlight=#{root.id}&thread=#{root.id}", Comment.deep_link_path(root)
  end
end
