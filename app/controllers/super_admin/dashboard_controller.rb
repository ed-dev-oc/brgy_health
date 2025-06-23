class SuperAdmin::DashboardController < SuperAdminController
  before_action :authorize_super_admin!

  def index
    @total_tenants = Barangay.count
    @admin_unvalidated = User.tagged_with([ "require_validation" ]).count
    @total_testimonials = Testimonial.count
    @total_reports = 0
    @users_per_region = User.joins(:barangay).group("barangays.region").count
  end

  private
  def authorize_super_admin!
    unless current_user&.super_admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
