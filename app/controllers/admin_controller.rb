class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :set_notifications

  def set_notifications
    @notifications = current_user.notifications.newest_first
  end
end
