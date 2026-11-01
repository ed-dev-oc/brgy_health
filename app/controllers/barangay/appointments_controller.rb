class Barangay::AppointmentsController < BarangayController
  before_action :authenticate_user!
  before_action :set_announcement, only: %i[create]
  before_action :set_appointment, only: %i[show cancel_schedule flag_as_reschedule]

  def index
    base_scope = current_user.appointments.includes(:announcement, :health_worker, :taggings)

    @all_visits_count = base_scope.count
    @upcoming_visits_count = base_scope.where(status: [ :pending, :approved ]).count
    @completed_visits_count = base_scope.where(status: :completed).count
    @cancelled_visits_count = base_scope.where(status: [ :cancelled, :rejected ]).count

    filtered_scope = case params[:filter]
    when "upcoming"
      base_scope.where(status: [ :pending, :approved ])
    when "completed"
      base_scope.where(status: :completed)
    when "cancelled"
      base_scope.where(status: [ :cancelled, :rejected ])
    else
      base_scope
    end

    @q = filtered_scope.ransack(params[:q])
    @pagy, @appointments = pagy(@q.result(distinct: true).order(scheduled_at: :desc, created_at: :desc), limit: 10)
  end

  def show
    @appointment.notifications.where(recipient: current_user).mark_as_read
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.barangay = current_tenant
    @appointment.announcement = @announcement
    @appointment.patient = current_user

    if @appointment.save
      flash[:notice] = "Appointment was successfully created."

      wait_until = @appointment.appointment_reminder_job_wait_until_condition

      if wait_until
        job = AppointmentReminderJob.set(wait_until: wait_until).perform_later(@appointment.id)

        @appointment.update_columns(reminder_job_id: job.job_id)
      end
    else
      flash.now[:alert] = "Appointment was not created."
    end
  end

  def cancel_schedule
    if @appointment.update(cancel_appointment_params)
      flash[:notice] = "Appointment was successfully cancelled."
    else
      flash[:alert] = "Appointment was not cancelled."
    end
  end

  def flag_as_reschedule
    @appointment.flag_list.add("rescheduled")

    if @appointment.update(reschedule_params)
      flash[:notice] = "Appointment was successfully rescheduled."

      admin_and_staff = @appointment.barangay.admin_and_staff
      AppointmentRescheduleNotifier.with(record: @appointment).deliver(admin_and_staff)
    else
      flash[:alert] = "Appointment was not rescheduled."
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:scheduled_at, :reason)
  end

  def cancel_appointment_params
    params.require(:appointment).permit(:cancel_reason).merge(status: :cancelled)
  end

  def reschedule_params
    params.require(:appointment).permit(:scheduled_at, :reschedule_reason, :reason).merge(status: :pending)
  end

  def set_appointment
    @appointment = Appointment.find_by_public_uid(params.expect(:id))

    if @appointment.nil?
      redirect_to appointments_path, status: :see_other, alert: "Appointment not found."
    end
  end

  def set_announcement
    @announcement = Announcement.find_by_public_uid(params.expect(:announcement_id))
  end
end
