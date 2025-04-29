class CreateAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements do |t|
      t.string :public_uid
      t.references :barangay, null: false, foreign_key: true
      t.references :posted_by, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.time :open_time
      t.time :close_time
      t.string :location
      t.integer :max_patients, default: 1
      t.string :audience
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :announcements, :public_uid, unique: true
  end
end
