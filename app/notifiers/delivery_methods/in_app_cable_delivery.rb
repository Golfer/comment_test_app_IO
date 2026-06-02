module DeliveryMethods
  class InAppCableDelivery < Noticed::DeliveryMethod
    def deliver
      notification = recipient.notifications.find_by(event: event)
      return unless notification

      Notifications::Cable.broadcast_notification(notification)
    end
  end
end
