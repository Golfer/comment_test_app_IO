module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      current_user.touch_presence!
    end

    private

    # Reuse the Devise/Warden session to authenticate the socket.
    def find_verified_user
      if (user = env["warden"]&.user)
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
