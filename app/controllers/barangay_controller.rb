class BarangayController < ApplicationController
  before_action :check_admin_flags

  private

  def check_admin_flags
    admin = ActsAsTenant.current_tenant.users.admin.first

    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false if admin.flag_list.include?("require_validation")
  end
end
