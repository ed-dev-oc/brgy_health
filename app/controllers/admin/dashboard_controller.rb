class Admin::DashboardController < AdminController
  def index
    @today_appointments_count = Appointment.where(scheduled_at: Time.current.all_day).count
    @today_completed_count = Appointment.where(scheduled_at: Time.current.all_day, status: :completed).count
    @pending_appointments_count = @sidebar_pending_appointments_count
    @waitlisted_appointments_count = Appointment.tagged_with("waitlisted").count

    @total_patients = User.patient.count
    @subdivisions_count = Subdivision.count
    @new_patients_this_month = User.patient.where(created_at: Time.current.beginning_of_month..Time.current).count
    @total_health_programs = HealthProgram.active.count
    @active_announcements_count = Announcement.active.count
    @total_health_workers = ActsAsTenant.current_tenant.admin_and_staff.count

    @pending_appointments = Appointment.includes(:patient, :announcement)
                                       .pending
                                       .order(scheduled_at: :asc)
                                       .limit(5)

    @today_appointments = Appointment.includes(:patient, :announcement, :health_worker)
                                     .where(scheduled_at: Time.current.all_day)
                                     .order(scheduled_at: :asc)
                                     .limit(5)

    @active_announcements = Announcement.includes(:health_program)
                                        .where(status: :active)
                                        .order(start_date: :asc)
                                        .limit(4)

    @line_chart_data = Appointment.joins(:announcement).group("announcements.name").group_by_week(:created_at).count
    @pie_data = HealthProgram.active.left_joins(:announcements).group("health_programs.name").count("announcements.id")

    # Advanced SQL Technique: CTE-computed health program performance metrics
    @program_performance_stats = HealthProgram.program_performance_summary(ActsAsTenant.current_tenant.id)
  end
end
