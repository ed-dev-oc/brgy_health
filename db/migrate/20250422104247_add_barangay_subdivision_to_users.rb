class AddBarangaySubdivisionToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :barangay, null: true, foreign_key: true
    add_reference :users, :subdivision, null: true, foreign_key: true
  end
end
