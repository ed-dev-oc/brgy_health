class SuperAdminController < ApplicationController
  layout "super_admin"
  before_action :have_current_tenant?
  before_action :set_notifications

  private

  def set_notifications
    @notifications = current_user.notifications.newest_first
  end

  def have_current_tenant?
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false if current_tenant
  end
end
