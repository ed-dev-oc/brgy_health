class SuperAdmin::DashboardController < SuperAdminController
  before_action :authorize_super_admin!
  
  def index
  end

  private
  def authorize_super_admin!
    unless current_user&.super_admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
