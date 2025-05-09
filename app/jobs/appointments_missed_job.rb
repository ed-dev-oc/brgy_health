class AppointmentsMissedJob < ApplicationJob
  queue_as :default

  def perform
    appointments = Appointment.approved.where("scheduled_at < ?", Time.now)

    appointments.find_each(batch_size: 100) do |appointment|
      appointment.flag_list.add("missed")
      if appointment.save
        AppointmentMissedNotifier.with(record: appointment).deliver(appointment.patient)
      end
    end
  end
end
