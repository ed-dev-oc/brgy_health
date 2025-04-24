class AddSubdomainToBarangay < ActiveRecord::Migration[8.0]
  def change
    add_column :barangays, :subdomain, :string
  end
end
