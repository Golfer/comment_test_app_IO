class NewCommentNotifier < Noticed::Event
  required_params :comment, :sender, :reason

  deliver_by :in_app_cable, class: "DeliveryMethods::InAppCableDelivery" do |config|
    config.queue = :notifications
  end

  deliver_by :email do |config|
    config.mailer = "NotificationMailer"
    config.method = :new_comment
    config.queue = :notifications
    config.if = -> { !recipient.online? }
  end

  deliver_by :push, class: "DeliveryMethods::PushDeliveryMethod" do |config|
    config.queue = :notifications
    config.if = -> { recipient.device_tokens.exists? }
  end

  notification_methods do
    def title
      Notifications::Presentation.title(reason)
    end

    def message_text
      Notifications::Presentation.message(
        reason: reason,
        sender_name: sender_name,
        preview: comment_preview
      )
    end

    def kind
      reason
    end

    def sender_name
      event.params[:sender_name] || event.params[:sender]&.display_name
    end

    def comment_id
      event.params[:comment_id] || event.params[:comment]&.id
    end

    def root_comment_id
      event.params[:root_comment_id] || event.params[:comment]&.root_id
    end

    def url
      event.params[:url] || Comment.deep_link_path(event.params[:comment])
    end

    def reason
      event.params[:reason].to_s
    end

    def comment_preview
      event.params[:comment_preview] || event.params[:comment]&.body_preview
    end
  end

  def comment_preview
    params[:comment].body_preview
  end
end
