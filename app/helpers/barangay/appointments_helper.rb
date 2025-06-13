module Barangay::AppointmentsHelper
  def display_resceduled_button?(appointment)
    Appointment::VALID_FOR_RESCHEDULE_STATUS.include?(@appointment.status.to_sym) && !@appointment.flag_list.include?("rescheduled")
  end
end
