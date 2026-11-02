class SuperAdminController < ApplicationController
  layout "super_admin"
  before_action :authenticate_user!
  before_action :check_super_admin
  before_action :have_current_tenant?

  private

  def have_current_tenant?
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false if current_tenant
  end

  def check_super_admin
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false unless current_user&.platform_user?
  end
end
