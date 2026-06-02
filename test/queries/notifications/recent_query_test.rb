require "test_helper"

module Notifications
  class RecentQueryTest < ActiveSupport::TestCase
    test "returns the unread count and recent notifications" do
      author = create(:user)
      recipient = create(:user)
      parent = create(:comment, user: recipient)

      perform_enqueued_jobs do
        Comments::CreateService.call(author: author, body: "reply", parent: parent)
      end

      page = Notifications::RecentQuery.call(user: recipient)
      assert_equal 1, page.unread_count
      assert_equal 1, page.notifications.size
    end
  end
end
