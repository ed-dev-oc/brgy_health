class BarangayController < ApplicationController
  layout "barangay"
  before_action :check_admin_flags
  before_action :set_notifications

  private

  def check_admin_flags
    admin = ActsAsTenant.current_tenant.users.admin.first

    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false if admin.flag_list.include?("require_validation")
  end

  def set_notifications
    if user_signed_in?
      @notifications = current_user.notifications.newest_first
    end
  end
end
