# Per-user stream for live in-app notifications + unread badge updates.
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_#{current_user.id}"
  end
end
