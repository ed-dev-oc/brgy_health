class AddImageUpdatedAtToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :image_updated_at, :datetime
  end
end
