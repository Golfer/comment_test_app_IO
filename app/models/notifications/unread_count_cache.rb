module Notifications
  module UnreadCountCache
    module_function

    def fetch(user)
      return 0 unless user

      Rails.cache.fetch(cache_key(user.id), expires_in: 30.seconds) do
        user.notifications.unread.count
      end
    end

    def reset(user)
      return unless user

      Rails.cache.delete(cache_key(user.id))
    end

    def cache_key(user_id)
      "users/#{user_id}/notifications/unread_count"
    end
  end
end
