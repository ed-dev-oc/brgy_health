# db/migrate/xxxxxxxxxx_create_event_views.rb
class CreateEventViews < ActiveRecord::Migration[8.0]
  def change
    create_table :event_views do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, foreign_key: true 
      t.string :ip_address

      t.timestamps
    end
  end
end
