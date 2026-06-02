module ApplicationHelper
  def unread_notifications_count
    return 0 unless current_user

    @unread_notifications_count ||= Notifications::UnreadCountCache.fetch(current_user)
  end

  def badge_count(count)
    count > 99 ? "99+" : count.to_s
  end
end
