class CreateTestimonials < ActiveRecord::Migration[8.0]
  def change
    create_table :testimonials do |t|
      t.references :barangay, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :data
      t.integer :rating, default: 1
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
