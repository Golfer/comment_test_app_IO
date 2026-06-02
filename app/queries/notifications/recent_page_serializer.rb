module Notifications
  module RecentPageSerializer
    module_function

    def call(page)
      {
        unread_count: page.unread_count,
        notifications: page.notifications.map { |notification| Serializer.call(notification) }
      }
    end
  end
end
