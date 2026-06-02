require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @author = create(:user)
    sign_in @user
    @parent = create(:comment, user: @user)
    perform_enqueued_jobs { Comments::CreateService.call(author: @author, body: "replying to you", parent: @parent) }
  end

  test "index returns notifications and unread count as json" do
    get notifications_path, as: :json
    assert_response :success
    assert_equal 1, response.parsed_body["unread_count"]
    notification = response.parsed_body["notifications"].first
    assert_equal 1, response.parsed_body["notifications"].size
    assert_equal @user.notifications.first.id, notification["id"]
    assert_equal "reply", notification["kind"]
  end

  test "index renders the notifications page as html" do
    get notifications_path
    assert_response :success
    assert_match "Reply to your comment", response.body
    assert_match "View reply in thread", response.body
  end

  test "show marks notification read and redirects to the thread" do
    notification = @user.notifications.first
    get notification_path(notification)
    assert_redirected_to notification.url
    assert notification.reload.read?
  end

  test "read marks a single notification" do
    notification = @user.notifications.first
    post read_notification_path(notification)
    assert_response :no_content
    assert notification.reload.read?
  end

  test "read_all marks every notification" do
    post read_all_notifications_path, as: :json
    assert_response :no_content
    assert_equal 0, @user.notifications.unread.count
  end
end
