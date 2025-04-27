class Subdivision < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :barangay

  validates :name, :barangay_id, presence: true
  validates :name, uniqueness: { scope: :barangay_id }
end
