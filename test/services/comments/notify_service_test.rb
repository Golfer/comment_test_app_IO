require "test_helper"

module Comments
  class NotifyServiceTest < ActiveSupport::TestCase
    test "notifies a mentioned user" do
      author = create(:user)
      mentioned = create(:user, name: "Bob Smith")
      comment = create(:comment, user: author, body: "hey @Bob check this")

      assert_difference -> { mentioned.notifications.count }, 1 do
        perform_comment_notifications(comment)
      end

      assert_equal "mention", mentioned.notifications.first.kind
    end

    test "notifies the parent author when someone replies" do
      thread = build_reply_thread

      assert_difference -> { thread[:parent_author].notifications.count }, 1 do
        perform_comment_notifications(thread[:reply])
      end

      notification = thread[:parent_author].notifications.first
      assert_equal "reply", notification.kind
      assert_match "replied to your comment", notification.message_text
    end

    test "notifies the root author when someone replies deeper in the thread" do
      thread = build_reply_thread(with_nested_parent: true)

      assert_difference -> { thread[:parent_author].notifications.count }, 1 do
        assert_difference -> { thread[:root_author].notifications.count }, 1 do
          perform_comment_notifications(thread[:reply])
        end
      end

      assert_equal "reply", thread[:parent_author].notifications.first.kind
      assert_equal "thread_reply", thread[:root_author].notifications.first.kind
      assert_match "replied in your thread", thread[:root_author].notifications.first.message_text
    end

    test "does not send thread reply when root author is the direct parent" do
      thread = build_reply_thread

      perform_comment_notifications(thread[:reply])

      assert_equal 1, thread[:parent_author].notifications.count
      assert_equal "reply", thread[:parent_author].notifications.first.kind
    end

    test "does not notify the author" do
      author = create(:user, last_seen_at: Time.current)
      comment = create(:comment, user: author, body: "solo post")

      assert_no_difference -> { author.notifications.count } do
        perform_comment_notifications(comment)
      end
    end

    test "reply reason takes precedence over mention for the parent author" do
      parent_author = create(:user, name: "Bob Smith")
      replier = create(:user)
      parent = create(:comment, user: parent_author)
      reply = create(:comment, user: replier, parent: parent, body: "thanks @Bob")

      perform_comment_notifications(reply)

      assert_equal 1, parent_author.notifications.count
      assert_equal "reply", parent_author.notifications.first.kind
    end
  end
end
