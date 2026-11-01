class SuperAdmin::DashboardController < SuperAdminController
  def index
    @total_tenants = Barangay.count
    @verified_tenants_count = Barangay.verified.count
    @unverified_tenants_count = [ @total_tenants - @verified_tenants_count, 0 ].max

    @admin_unvalidated = User.tagged_with([ "require_validation" ]).count
    @pending_admins = User.includes(:barangay)
                          .where(role: :admin)
                          .tagged_with([ "require_validation" ])
                          .order(created_at: :desc)
                          .limit(5)

    @total_users = User.count
    @admins_count = User.admin.count
    @staff_count = User.staff.count
    @patients_count = User.patient.count

    @total_testimonials = Testimonial.count
    @average_rating = Testimonial.average(:rating)&.round(1) || 0.0
    @recent_testimonials = Testimonial.includes(:user, :barangay).order(created_at: :desc).limit(5)

    @total_reports = IssueReport.count
    @open_reports_count = IssueReport.open.count
    @critical_reports_count = IssueReport.open.critical.count
    @recent_issues = IssueReport.order(created_at: :desc).limit(5)

    @barangays_by_month = Barangay.group_by_month(:created_at).count
    @users_per_region = User.joins(:barangay).group("barangays.region").count
  end
end
