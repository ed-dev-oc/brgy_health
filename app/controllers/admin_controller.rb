class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :set_notifications
  before_action :authenticate_user_role

  private

  def set_notifications
    @notifications = current_user.notifications.newest_first
  end

  def authenticate_user_role
    redirect_to root_path unless current_user.role == "admin" || current_user.role == "staff"
  end
end
