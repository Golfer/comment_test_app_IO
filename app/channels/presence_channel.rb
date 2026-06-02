# Global presence: announces who is online/offline to all connected clients.
class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from Users::PresenceCable::STREAM
    current_user.touch_presence!
    Users::PresenceCable.broadcast(current_user, online: true)
  end

  def unsubscribed
    current_user.clear_presence!
    Users::PresenceCable.broadcast(current_user, online: false)
  end

  # Client heartbeat to keep last_seen_at fresh while the tab is open.
  def ping
    current_user.touch_presence!
  end
end
