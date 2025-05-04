class Barangay::AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_announcement, only: %i[create]

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

  private

  def appointment_params
    params.require(:appointment).permit(:scheduled_at, :notes)
  end

  def set_announcement
    @announcement = Announcement.find_by_public_uid(params.expect(:announcement_id))
  end
end
