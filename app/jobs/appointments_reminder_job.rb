class AppointmentsReminderJob < ApplicationJob
  queue_as :default

  def perform
    today = Time.zone.today
    appointments = Appointment.approved.where(scheduled_at: today.beginning_of_day..today.end_of_day)

    appointments.find_each(batch_size: 100) do |appointment|
      AppointmentReminderNotifier.with(record: appointment).deliver(appointment.patient)
    end
  end
end
