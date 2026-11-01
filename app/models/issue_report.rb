class IssueReport < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  has_many_attached :images
  enum :issue_type, [ :bug, :feature_request, :ui_ux, :security ]
  enum :priority, [ :low, :medium, :high, :critical ]
  enum :module_area, [ :authentication, :dashboard, :reports, :profile, :database, :appointment, :event, :announcement, :other ]
  enum :status, [ :open, :in_progress, :resolved, :closed ]

  validates :issue_type, :title, :description, :priority, :module_area, :email, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "description", "email", "id", "issue_type", "module_area", "priority", "public_uid", "status", "title", "updated_at", "url" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "images_attachments", "images_blobs" ]
  end
end
