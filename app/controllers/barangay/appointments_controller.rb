class Barangay::AppointmentsController < BarangayController
  before_action :authenticate_user!
  before_action :set_announcement, only: %i[create]
  before_action :set_appointment, only: %i[show cancel_schedule flag_as_reschedule]

  def index
    @q = current_user.appointments.ransack(params[:q])
    @pagy, @appointments = pagy(@q.result(distinct: true).order(created_at: :desc), limit: 5)
  end

  def show
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.barangay = current_tenant
    @appointment.announcement = @announcement
    @appointment.patient = current_user

    if @appointment.save
      ActivityLog.create!(
        user: current_user,
        action: "created",
        description: "Initial Satus: #{@appointment.status}",
        loggable: @appointment
      )
      flash[:notice] = "Appointment was successfully created."
    else
      flash.now[:alert] = "Appointment was not created."
    end
  end

  def cancel_schedule
    if @appointment.update(cancel_appointment_params)
      ActivityLog.create!(
        user: current_user,
        action: "cancelled",
        description: "Cancel reason: #{@appointment.cancel_reason}",
        loggable: @appointment
      )
      flash[:notice] = "Appointment was successfully cancelled."
    else
      flash[:alert] = "Appointment was not cancelled."
    end
  end

  def flag_as_reschedule
     @appointment.flag_list.add("rescheduled")

     current_schedule = @appointment.scheduled_at
     @appointment.assign_attributes(reschedule_params)

    if @appointment.scheduled_at.present?
       description = "Change from #{current_schedule.strftime("%B %d, %Y %I:%M %p")} Change to #{@appointment.scheduled_at.strftime("%B %d, %Y %I:%M %p")}"
    else
       description = "Appointment was flagged as rescheduled."
    end

    if @appointment.save
      ActivityLog.create!(
        user: current_user,
        action: "rescheduled",
        description: description,
        loggable: @appointment
      )
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
