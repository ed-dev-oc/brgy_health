class AddHealthProgramToAnnouncements < ActiveRecord::Migration[8.0]
  def change
    add_reference :announcements, :health_program, null: false, foreign_key: true
  end
end
