class AddImageUpdatedAtToAnnouncements < ActiveRecord::Migration[8.0]
  def change
    add_column :announcements, :image_updated_at, :datetime
  end
end
