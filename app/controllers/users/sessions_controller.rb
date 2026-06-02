module Users
  class SessionsController < Devise::SessionsController
    def destroy
      user = current_user
      super
    ensure
      if user
        user.clear_presence!
        Users::PresenceCable.broadcast(user, online: false)
      end
    end
  end
end
