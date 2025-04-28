class CreateAdminHealthPrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_health_programs do |t|
      t.references :barangay, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.integer :status

      t.timestamps

    end
  end
end
