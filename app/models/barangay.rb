class Barangay < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: [ :slugged, :finders ]

  has_many :subdivisions
  has_many :users
  has_many :health_programs
  has_many :testimonials

  acts_as_taggable_on :flags

  enum :subdivision_type, [ :both, :purok, :zone ]

  validates :name, :region, :province, :city, presence: true
  validates :name, uniqueness: { scope: [ :region, :province, :city ] }

  after_validation :set_subdomain_from_slug
  after_create :generate_pages

  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  def admin_and_staff
    users.where(role: [ :admin, :staff ])
  end

  def full_address
    "#{name}, #{city}, #{province}, #{region}"
  end

  def verified_status
    verified? ? "Verified" : "Unverified"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      admin_id
      city
      created_at
      id
      id_value
      name
      province
      region
      slug
      subdivision_type
      subdomain
      updated_at
      verified
    ]
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
    self.subdomain = slug if subdomain.blank?
  end

  def generate_pages
    BarangayGeneratePagesJob.perform_later(self.id)
  end
end
