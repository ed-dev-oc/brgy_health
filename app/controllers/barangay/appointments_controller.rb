class Barangay::AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_announcement, only: %i[create]
  before_action :set_appointment, only: %i[flag_as_cancelled]

  def index
    @q = current_user.appointments.ransack(params[:q])
    @pagy, @appointments = pagy(@q.result(distinct: true))
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

  def flag_as_cancelled
    @appointment.flag_list = []
    @appointment.flag_list.add("cancelled")
    if @appointment.save
      redirect_to appointments_path, notice: "Appointment was successfully cancelled."
    else
      redirect_to appointments_path, alert: "Appointment failed to be cancelled."
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:scheduled_at, :reason)
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
