module Notifications
  # Action Cable broadcasts for live badge and notification list updates.
  module Cable
    module_function

    def stream_for(user)
      "notifications_#{user.id}"
    end

    def broadcast_unread_count(user)
      ActionCable.server.broadcast(
        stream_for(user),
        {
          type: "notification",
          unread_count: UnreadCountCache.fetch(user)
        }
      )
    end

    def broadcast_notification(notification)
      recipient = notification.recipient
      UnreadCountCache.reset(recipient)

      ActionCable.server.broadcast(
        stream_for(recipient),
        {
          type: "notification",
          notification: Serializer.cable_payload(notification),
          unread_count: UnreadCountCache.fetch(recipient)
        }
      )
    end
  end
end
