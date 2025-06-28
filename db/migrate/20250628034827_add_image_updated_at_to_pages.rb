class AddImageUpdatedAtToPages < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :image_updated_at, :datetime
  end
end
