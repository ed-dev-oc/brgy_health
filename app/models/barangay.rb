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

  scope :verified, -> { tagged_with("verified") }
  scope :unverified, -> { where.not(id: tagged_with("verified")) }

  def admin_and_staff
    users.where(role: [ :admin, :staff ])
  end

  def full_address
    "#{name}, #{city}, #{province}, #{region}"
  end

  def has_validated_admin?
    users.where(role: :admin).where.not(id: User.tagged_with("require_validation").pluck(:id)).exists?
  end

  def verified?
    has_validated_admin?
  end

  def verified_status
    verified? ? "Verified" : "Unverified"
  end

  def has_unvalidated_admin?
    unvalidated_admin.present?
  end

  def unvalidated_admin
    users.where(role: :admin).tagged_with("require_validation").first
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      name
      city
      province
      region
      created_at
      updated_at
      verified_status
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      users
      testimonials
      health_programs
      subdivisions
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
