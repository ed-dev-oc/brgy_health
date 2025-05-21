class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :public_uid
      t.references :barangay, null: false, foreign_key: true
      t.references :posted_by, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.integer :audience, default: 0
      t.string :location
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
