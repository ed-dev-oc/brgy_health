class Admin::DashboardController < AdminController
  def index
    @today_appointments_count = Appointment.where("DATE(created_at) = ?", Date.today).count
    @total_patients = User.patient.count
    @total_health_programs = HealthProgram.active.count
    @total_health_workers = ActsAsTenant.current_tenant.admin_and_staff.count
    @line_chart_data = Appointment.joins(:announcement).group("announcements.name").group_by_week(:created_at).count
    @pie_data = HealthProgram.active.left_joins(:announcements).group("health_programs.name").count("announcements.id")
  end
end
