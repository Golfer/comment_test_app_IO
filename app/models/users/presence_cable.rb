module Users
  # Action Cable broadcasts for live online/offline status.
  module PresenceCable
    STREAM = "presence"

    module_function

    def broadcast(user, online:)
      ActionCable.server.broadcast(
        STREAM,
        { type: "presence", user_id: user.id, online: online }
      )
    end
  end
end
