class RemoveNameIndexToBarangay < ActiveRecord::Migration[8.0]
  def change
    remove_index :barangays, :name
  end
end
