class AddImageUpdatedAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :image_updated_at, :datetime
  end
end
