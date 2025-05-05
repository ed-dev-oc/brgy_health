class ChangeReasonNotesTypeInAppointments < ActiveRecord::Migration[8.0]
  def change
    change_column :appointments, :reason, :text
    change_column :appointments, :notes, :text
  end
end
