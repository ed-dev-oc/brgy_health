class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.newest_first
  end

  def mark_all_as_read
    current_user.notifications.mark_as_read
    @notifications = current_user.notifications.newest_first
  end

  def read
    @notifications = current_user.notifications.read.newest_first
  end

  def unread
    @notifications = current_user.notifications.unread.newest_first
  end

  def status
    @notifications = current_user.notifications.unread.newest_first
  end
end
