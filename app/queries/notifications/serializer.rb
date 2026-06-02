module Notifications
  # JSON shape for API and Action Cable payloads.
  module Serializer
    module_function

    def call(notification)
      {
        id: notification.id,
        read: notification.read?,
        created_at: notification.created_at.iso8601,
        title: safe(notification, :title),
        text: safe(notification, :message_text),
        kind: safe(notification, :kind),
        url: safe(notification, :url),
        sender_name: safe(notification, :sender_name),
        comment_id: safe(notification, :comment_id),
        root_comment_id: safe(notification, :root_comment_id)
      }
    end

    def cable_payload(notification)
      call(notification).merge(
        sender: safe(notification, :sender_name),
        preview: safe(notification, :comment_preview)
      )
    end

    def safe(notification, method)
      notification.public_send(method)
    rescue StandardError
      nil
    end
  end
end
