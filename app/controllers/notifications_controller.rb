class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    page = Notifications::RecentQuery.call(user: current_user)
    @notifications = page.notifications
    @unread_count = page.unread_count

    respond_to do |format|
      format.html
      format.json { render json: Notifications::RecentPageSerializer.call(page) }
    end
  end

  def show
    mark_read!(current_user.notifications.find(params[:id]))
    redirect_to notification_destination(@notification)
  end

  def read
    mark_read!(current_user.notifications.find(params[:id]))
    head :no_content
  end

  def read_all
    current_user.notifications.unread.mark_as_read
    Notifications::UnreadCountCache.reset(current_user)
    broadcast_unread_count!
    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
      format.json { head :no_content }
    end
  end

  private

  def mark_read!(notification)
    @notification = notification
    notification.mark_as_read!
    Notifications::UnreadCountCache.reset(current_user)
    broadcast_unread_count!
  end

  def broadcast_unread_count!
    Notifications::Cable.broadcast_unread_count(current_user)
  end

  def notification_destination(notification)
    Notifications::Serializer.safe(notification, :url).presence || comments_path
  end
end
