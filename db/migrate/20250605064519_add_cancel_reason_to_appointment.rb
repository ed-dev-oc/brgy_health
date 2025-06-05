class AddCancelReasonToAppointment < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :cancel_reason, :text, null: true
  end
end
