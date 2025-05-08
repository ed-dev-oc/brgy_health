class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :public_uid, :string
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :suffix, :string
    add_column :users, :phone_number, :string
    add_column :users, :role, :integer

    add_index :users, :role
    add_index :users, :public_uid, unique: true
    add_index :users, :phone_number, unique: true
    add_index :users, [ :first_name, :middle_name, :last_name, :suffix ], unique: true, name: "index_users_on_full_name"
  end
end
