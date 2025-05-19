class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.references :barangay, null: true, foreign_key: true
      t.string :name
      t.string :slug
      t.string :title
      t.string :subheadline
      t.integer :section
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
  end
end
