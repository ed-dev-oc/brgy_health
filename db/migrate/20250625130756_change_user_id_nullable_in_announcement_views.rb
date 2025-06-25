class ChangeUserIdNullableInAnnouncementViews < ActiveRecord::Migration[8.0]
  def change
    change_column_null :announcement_views, :user_id, true
  end
end
