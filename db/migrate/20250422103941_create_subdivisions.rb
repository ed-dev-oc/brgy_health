class CreateSubdivisions < ActiveRecord::Migration[8.0]
  def change
    create_table :subdivisions do |t|
      t.references :barangay, null: false, foreign_key: true
      t.string :name
      t.string :slug

      t.timestamps
    end

    add_index :subdivisions, [ :name, :barangay_id ], unique: true, name: "index_subdivisions_on_name_and_barangay_id"
    add_index :subdivisions, [ :slug, :barangay_id ], unique: true, name: "index_subdivisions_on_slug_and_barangay_id"
  end
end
