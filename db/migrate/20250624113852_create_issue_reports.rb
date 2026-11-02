class CreateIssueReports < ActiveRecord::Migration[8.0]
  def change
    create_table :issue_reports do |t|
      t.integer :issue_type, default: 0
      t.string :title
      t.text :description
      t.integer :priority, default: 0
      t.integer :module_area, default: 0
      t.string :url
      t.string :email

      t.timestamps
    end
  end
end
