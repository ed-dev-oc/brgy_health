class Barangay < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: [ :slugged, :finders ]

  has_many :subdivisions
  has_many :users
  has_many :health_programs
  acts_as_taggable_on :flags
  has_many :health_programs

  enum :subdivision_type, [ :both, :purok, :zone ]
  validates :name, :region, :province, :city, presence: true

  validates :name, uniqueness: { scope: [ :region, :province, :city ] }

  after_validation :set_subdomain_from_slug

  def admin_and_staff
    users.where(role: [ :admin, :staff ])
  end

  def full_address
    "#{name}, #{city}, #{province}, #{region}"
  end

  private

  def slug_candidates
    [
      :name,
      -> { "#{name}-#{city}" },
      -> { "#{name}-#{city}-#{province}" }
    ]
  end

  def set_subdomain_from_slug
    self.subdomain = slug
  end
end
