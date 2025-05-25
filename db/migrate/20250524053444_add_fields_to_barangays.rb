class AddFieldsToBarangays < ActiveRecord::Migration[8.0]
  def change
    add_column :barangays, :verified, :boolean
    add_column :barangays, :admin_id, :integer
  end
end
