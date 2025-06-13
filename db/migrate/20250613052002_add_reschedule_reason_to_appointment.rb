class AddRescheduleReasonToAppointment < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :reschedule_reason, :text, null: true
  end
end
