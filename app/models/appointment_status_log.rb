class AppointmentStatusLog < ApplicationRecord
  belongs_to :appointment

  enum :old_status, Appointment.statuses, prefix: :old, allow_nil: true
  enum :new_status, Appointment.statuses, prefix: :new, allow_nil: true

  # Populated automatically by PostgreSQL trigger: trg_appointment_status_transition
  def readonly?
    !new_record?
  end
end
