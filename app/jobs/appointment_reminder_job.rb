class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(id)
    appointment = Appointment.find_by(id: id)
    return unless appointment&.approved?

    AppointmentReminderNotifier.with(record: appointment).deliver(appointment.patient)

    if wait_until = appointment.appointment_reminder_job_wait_until_condition
      scheduled_job = AppointmentReminderJob.set(wait_until: wait_until).perform_later(appointment.id)

      if scheduled_job.respond_to?(:job_id)
        appointment.update(reminder_job_id: scheduled_job.job_id)
      end
    end
  end
end
