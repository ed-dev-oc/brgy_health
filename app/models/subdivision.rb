class Subdivision < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  acts_as_tenant(:barangay)

  validates :name, :barangay_id, presence: true
  validates :name, uniqueness: { scope: :barangay_id }
end
