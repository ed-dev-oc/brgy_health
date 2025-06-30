class AnnouncementView < ApplicationRecord
  belongs_to :announcement
  belongs_to :user, optional: true

  validates :user_id, uniqueness: { scope: :announcement_id }, if: -> { user.present? }
  validates :ip_address, uniqueness: { scope: :announcement_id }, if: -> { user.blank? }

end
