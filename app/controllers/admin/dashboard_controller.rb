class Admin::DashboardController < AdminController
  before_action :authorize_admin!

  def index
  end

  private
  def authorize_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
