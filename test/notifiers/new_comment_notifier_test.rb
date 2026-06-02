require "test_helper"

class NewCommentNotifierTest < ActiveSupport::TestCase
  test "persists a reply notification with deep link url" do
    subject = build_reply_notification_subject

    deliver_comment_notification(
      recipient: subject[:recipient],
      sender: subject[:sender],
      comment: subject[:comment]
    )

    notification = subject[:recipient].notifications.first
    assert_not_nil notification
    assert_equal "Reply to your comment", notification.title
    assert_match "Alice", notification.message_text
    assert_match "replied to your comment", notification.message_text
    assert_equal "/comments?highlight=#{subject[:comment].id}&thread=#{subject[:parent].id}", notification.url
  end

  test "broadcasts an in-app notification over Action Cable" do
    subject = build_reply_notification_subject(sender_name: "Sender")

    assert_broadcasts("notifications_#{subject[:recipient].id}", 1) do
      deliver_comment_notification(
        recipient: subject[:recipient],
        sender: subject[:sender],
        comment: subject[:comment]
      )
    end
  end

  test "delivers email only when the recipient is offline" do
    subject = build_reply_notification_subject(recipient_online: false, body: "Hello everyone")

    assert_emails 1 do
      deliver_comment_notification(
        recipient: subject[:recipient],
        sender: subject[:sender],
        comment: subject[:comment]
      )
    end

    email = ActionMailer::Base.deliveries.last
    assert_match "replied to your comment", email.subject
    assert_match(/Hello everyone/, email.body.encoded)
  end

  test "does not email an online recipient" do
    subject = build_reply_notification_subject(sender_name: "Sender")

    assert_no_emails do
      deliver_comment_notification(
        recipient: subject[:recipient],
        sender: subject[:sender],
        comment: subject[:comment]
      )
    end
  end
end
