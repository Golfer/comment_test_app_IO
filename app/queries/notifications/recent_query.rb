module Notifications
  # Recent notifications for a user plus the current unread count.
  class RecentQuery < ApplicationQuery
    DEFAULT_LIMIT = 30

    def initialize(user:, limit: DEFAULT_LIMIT)
      @user = user
      @limit = limit
    end

    def call
      notifications = EventParamsPreloader.call(
        @user.notifications.newest_first.limit(@limit).includes(:event).to_a
      )

      RecentPage.new(
        unread_count: UnreadCountCache.fetch(@user),
        notifications: notifications
      )
    end
  end
end
