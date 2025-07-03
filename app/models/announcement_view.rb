class AnnouncementView < ApplicationRecord
  belongs_to :announcement
  belongs_to :user, optional: true

  validates :user_id, uniqueness: { scope: :announcement_id }, allow_nil: true
  validates :ip_address, uniqueness: { scope: [ :announcement_id, :user_id ] }, if: -> { user_id.nil? }
end
