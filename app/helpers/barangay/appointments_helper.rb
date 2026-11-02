module Barangay::AppointmentsHelper
  def display_resceduled_button?(appointment)
    target = appointment || @appointment
    return false unless target

    Appointment::VALID_FOR_RESCHEDULE_STATUS.include?(target.status.to_sym) && !target.flag_list.include?("rescheduled")
  end
end
