class Admin::AppointmentsController < AdminController
  before_action :set_appointment, only: [ :show, :flag_as_rejected, :flag_as_approved, :follow_up_check_up, :flag_as_completed, :cancel_schedule ]

  def index
    @q = Appointment.ransack(params[:q])
    @pagy, @appointments = pagy(@q.result(distinct: true).order(created_at: :desc))
  end

  def show
    if @appointment.completed?
      @new_appointment = Appointment.new
    end

    @appointment.notifications.where(recipient: current_user).mark_as_read
  end

  def flag_as_rejected
    if @appointment.rejected!
      flash.notice = "Appointment was successfully rejected."

      redirect_back fallback_location: admin_appointments_path
    else
      flash.alert = "Appointment was not rejected."

      redirect_back fallback_location: admin_appointments_path
    end
  end

  def flag_as_approved
    if @appointment.update(status: :approved, health_worker: current_user)
      flash.notice = "Appointment was successfully accepted."

      redirect_back fallback_location: admin_appointments_path
    else
      flash.alert = "Appointment was not accepted."

      redirect_back fallback_location: admin_appointments_path, status: :unprocessable_entity
    end
  end

  def flag_as_completed
    if @appointment.update(flag_as_completed_params)
      flash.notice = "Appointment was successfully completed."
    else
      flash.alert = "Appointment was not completed."
    end
  end

  def follow_up_check_up
    @new_appointment = Appointment.new(follow_up_check_up_params)
    @new_appointment.barangay = current_tenant
    @new_appointment.announcement = @appointment.announcement
    @new_appointment.patient = @appointment.patient
    @new_appointment.follow_up = @appointment
    @appointment.flag_list.add("follow_up_check_up")

    if @new_appointment.save && @appointment.save
      flash.notice = "New follow up was successfully created."
    else
      flash.alert = "New follow up was not created."
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

  def flag_as_completed_params
    params.require(:appointment).permit(:notes)
  end

  def follow_up_check_up_params
    params.require(:appointment).permit(:scheduled_at, :reason)
  end

  def cancel_appointment_params
    params.require(:appointment).permit(:cancel_reason).merge(status: :cancelled)
  end

  def set_appointment
    @appointment = Appointment.find_by_public_uid(params.expect(:id))

    if @appointment.nil?
      redirect_to admin_appointments_path, status: :see_other, alert: "Appointment not found."
    end
  end
end
