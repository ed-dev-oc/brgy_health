class Barangay < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: [ :slugged, :finders ]

  has_many :subdivisions
  has_many :users
  has_many :health_programs
  acts_as_taggable_on :flags
  has_many :health_programs
  has_many :testimonials

  enum :subdivision_type, [ :both, :purok, :zone ]
  validates :name, :region, :province, :city, presence: true

  validates :name, uniqueness: { scope: [ :region, :province, :city ] }

  after_validation :set_subdomain_from_slug
  after_create :generate_pages

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

  def generate_pages
    BarangayGeneratePagesJob.perform_later(self.id)
  end
end
