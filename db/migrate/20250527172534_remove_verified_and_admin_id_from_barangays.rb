class RemoveVerifiedAndAdminIdFromBarangays < ActiveRecord::Migration[8.0]
  def change
    remove_column :barangays, :verified, :boolean
    remove_column :barangays, :admin_id, :integer
  end
end
