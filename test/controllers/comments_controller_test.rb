require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "index returns total and matched comments as json" do
    matched = create(:comment, body: "needle in haystack")
    create(:comment, body: "unrelated")

    get comments_path, params: { q: "needle" }, as: :json

    assert_response :success
    assert_equal 1, response.parsed_body["total"]
    assert_equal matched.id, response.parsed_body.dig("hits", 0, "id")
  end

  test "create posts a root comment" do
    assert_difference "Comment.count", 1 do
      post_comment(body: "hello")
    end
    assert_response :created
  end

  test "create posts a reply" do
    parent = create(:comment)
    post_reply(parent: parent, body: "reply", format: :json)
    assert_response :created
    assert_equal parent.id, response.parsed_body["parent_id"]
  end

  test "create rejects a blank comment" do
    post_comment(body: "")
    assert_response :unprocessable_entity
  end

  test "index searches comments by query" do
    create(:comment, body: "needle in haystack")
    get comments_path, params: { q: "needle" }
    assert_response :success
    assert_match "needle", response.body
  end

  test "index shows requested thread root from search deep link" do
    old_root = create(:comment, body: "older root", created_at: 3.days.ago)
    child = create(:comment, parent: old_root, body: "target reply")
    100.times { create(:comment, body: "recent root", created_at: 1.day.ago) }

    get comments_path, params: { thread: old_root.id, highlight: child.id }

    assert_response :success
    assert_match "older root", response.body
  end

  test "create posts a reply as turbo stream and broadcasts via service" do
    parent = create(:comment, body: "parent")
    assert_difference "Comment.count", 1 do
      post_reply(parent: parent, body: "my reply", format: :turbo_stream)
    end
    assert_response :success
    assert_equal "my reply", Comment.last.body
  end

  test "create reply notifies the parent author immediately" do
    parent_author = create(:user)
    parent = create(:comment, user: parent_author, body: "parent")
    replier = create(:user)
    sign_in replier

    assert_difference -> { parent_author.notifications.count }, 1 do
      perform_enqueued_jobs do
        post_reply(parent: parent, body: "my reply", format: :turbo_stream)
      end
    end

    notification = parent_author.notifications.last
    assert_equal "reply", notification.kind
    assert_match "replied to your comment", notification.message_text
  end

  test "replies renders the full thread under a comment" do
    root = create(:comment, body: "root")
    child = create(:comment, parent: root, body: "child")
    create(:comment, parent: child, body: "grandchild")

    get replies_comment_path(root)
    assert_response :success
    assert_match "child", response.body
    assert_match "grandchild", response.body
    assert_match "title=\"1 reply in this thread\"", response.body
    assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(root, :replies)}"
    assert_select 'form[data-turbo-frame="_top"]'
  end
end
