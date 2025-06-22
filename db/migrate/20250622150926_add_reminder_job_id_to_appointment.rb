class AddReminderJobIdToAppointment < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :reminder_job_id, :string, null: true
  end
end
