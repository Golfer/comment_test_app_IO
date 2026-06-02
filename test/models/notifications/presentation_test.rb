require "test_helper"

class NotificationsPresentationTest < ActiveSupport::TestCase
  test "title and message for each reason" do
    assert_equal "Reply to your comment", Notifications::Presentation.title("reply")
    assert_equal "New reply in your thread", Notifications::Presentation.title("thread_reply")
    assert_match "replied in your thread", Notifications::Presentation.message(
      reason: "thread_reply",
      sender_name: "Alice",
      preview: "Hi"
    )
  end
end
