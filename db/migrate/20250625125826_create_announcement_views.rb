class CreateAnnouncementViews < ActiveRecord::Migration[8.0]
  def change
    create_table :announcement_views do |t|
      t.references :announcement, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :ip_address

      t.timestamps
    end
  end
end
