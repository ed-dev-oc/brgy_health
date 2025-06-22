class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(id)
    appointment = Appointment.find_by(id: id)

    if appointment.present? && appointment.approved?
      AppointmentReminderNotifier.with(record: appointment).deliver(appointment.patient)
      wait_until = appointment.appointment_reminder_job_wait_until_condition

      if wait_until
        job_id = AppointmentReminderJob.set(wait_until: wait_until).perform_later(appointment.id)

        appointment.update_columns(reminder_job_id: job_id)
      end
    end
  end
end
