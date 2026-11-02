class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.string :public_uid
      t.references :barangay, null: false, foreign_key: true
      t.references :announcement, null: false, foreign_key: true
      t.references :health_worker, null: true, foreign_key: { to_table: :users }
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.datetime :scheduled_at
      t.string :reason
      t.string :notes
      t.references :follow_up, null: true, foreign_key: { to_table: :appointments }

      t.timestamps
    end
  end
end
