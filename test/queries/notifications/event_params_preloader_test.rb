require "test_helper"

module Notifications
  class EventParamsPreloaderTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "preloads legacy notification params in a single batch" do
      recipient = create(:user)
      sender = create(:user, name: "Alice")
      comment = create(:comment, user: sender, body: "hello")

      perform_enqueued_jobs do
        NewCommentNotifier.with(comment: comment, sender: sender, reason: "reply").deliver(recipient)
      end

      notifications = recipient.notifications.includes(:event).to_a
      assert_equal 1, notifications.size

      queries = []
      callback = lambda { |*, payload| queries << payload[:sql] if payload[:sql] }

      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        EventParamsPreloader.call(notifications)
        notifications.each do |notification|
          assert_equal "Alice", notification.sender_name
          assert notification.url.present?
        end
      end

      comment_queries = queries.count { |sql| sql.include?("FROM \"comments\"") && sql.include?("WHERE") }
      user_queries = queries.count { |sql| sql.include?("FROM \"users\"") && sql.include?("WHERE") }

      assert_operator comment_queries, :<=, 1
      assert_operator user_queries, :<=, 1
    end

    test "uses snapshot params without loading comment records" do
      recipient = create(:user)
      sender = create(:user, name: "Bob")
      parent = create(:comment, user: recipient)
      comment = create(:comment, user: sender, parent: parent, body: "snapshotted")

      perform_enqueued_jobs do
        Comments::NotifyService.call(comment)
      end

      notification = recipient.notifications.includes(:event).first

      EventParamsPreloader.call([ notification ])

      assert_no_queries do
        assert_equal "Bob", notification.sender_name
        assert_equal Comment.deep_link_path(comment), notification.url
      end
    end
  end
end
