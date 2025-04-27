class CreateBarangays < ActiveRecord::Migration[8.0]
  def change
    create_table :barangays do |t|
      t.string :name
      t.string :slug
      t.integer :subdivision_type, default: 0
      t.string :region
      t.string :province
      t.string :city

      t.timestamps
    end
    add_index :barangays, :name, unique: true
    add_index :barangays, [ :region, :province, :city, :slug ], unique: true, name: "index_barangays_on_region_and_province_and_city_and_slug"
    add_index :barangays, [ :region, :province, :city, :name ], unique: true, name: "index_barangays_on_region_and_province_and_city_and_name"
  end
end
