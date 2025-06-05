class Barangay::AppointmentsController < BarangayController
  before_action :authenticate_user!
  before_action :set_announcement, only: %i[create]
  before_action :set_appointment, only: %i[show cancel_schedule]

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
      flash[:notice] = "Appointment was successfully created."
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

  private

  def appointment_params
    params.require(:appointment).permit(:scheduled_at, :reason)
  end

  def cancel_appointment_params
    params.require(:appointment).permit(:cancel_reason).merge(status: :cancelled)
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
