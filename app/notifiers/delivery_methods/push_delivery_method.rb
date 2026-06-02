module DeliveryMethods
  class PushDeliveryMethod < Noticed::DeliveryMethod
    def deliver
      tokens = recipient.device_tokens
      return if tokens.empty?

      notification = recipient.notifications.find_by(event: event)
      tokens.each { |device| dispatch(device, payload(notification)) }
    end

    private

    def payload(notification)
      comment = event.params[:comment]
      sender = event.params[:sender]
      reason = event.params[:reason].to_s
      preview = event.comment_preview

      {
        title: notification&.title || Notifications::Presentation.title(reason),
        body: notification&.message_text || Notifications::Presentation.message(
          reason: reason,
          sender_name: sender.display_name,
          preview: preview
        ),
        data: {
          comment_id: comment.id,
          root_comment_id: comment.root.id,
          url: Comment.deep_link_path(comment)
        }
      }
    end

    def dispatch(device, payload)
      Rails.logger.info(
        "[PushDeliveryMethod] would push to #{device.platform} token=#{device.token.truncate(12)} payload=#{payload.inspect}"
      )
    end
  end
end
