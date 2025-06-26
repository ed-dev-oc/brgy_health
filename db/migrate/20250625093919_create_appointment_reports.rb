class CreateAppointmentReports < ActiveRecord::Migration[8.0]
  def change
    create_view :appointment_reports
  end

  def down
    drop_view :appointment_reports
  end
end
