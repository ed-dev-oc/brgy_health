class AnnouncementView < ApplicationRecord
  belongs_to :announcement
  belongs_to :user, optional: true

  validates :ip_address, uniqueness: { scope: :announcement_id }
end
