class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :authenticate_user_role
  before_action :generate_testimonial
  before_action :set_admin_sidebar_counts

  private

  def authenticate_user_role
    redirect_to root_path unless current_user.role == "admin" || current_user.role == "staff"
  end

  def generate_testimonial
    if current_user.role == "admin"
      @testimonial = current_user.testimonial.nil? ? Testimonial.new : nil
      @sidebar_testimonial = current_user.testimonial || Testimonial.new
    end
  end

  def set_admin_sidebar_counts
    @sidebar_pending_appointments_count = Appointment.pending.count
    @sidebar_today_appointments_count = Appointment.where(scheduled_at: Time.current.all_day, status: [ :approved, :completed ]).count
  end
end
