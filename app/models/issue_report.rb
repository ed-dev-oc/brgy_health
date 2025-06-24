class IssueReport < ApplicationRecord
  has_many_attached :images
  enum :issue_type, [ :bug, :feature_request, :ui_ux, :security ]
  enum :priority, [ :low, :medium, :high, :critical ]
  enum :module_area, [ :authentication, :dashboard, :reports, :profile, :database, :appointment, :event, :announcement, :other ]

  validates :issue_type, :title, :description, :priority, :module_area, :email, presence: true
end
