class AddStatusPublicUidToIssueReport < ActiveRecord::Migration[8.0]
  def change
    add_column :issue_reports, :status, :integer, default: 0
    add_column :issue_reports, :public_uid, :string
  end
end
