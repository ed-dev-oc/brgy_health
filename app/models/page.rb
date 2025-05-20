class Page < ApplicationRecord
  acts_as_tenant :barangay, optional: true

  has_one_attached :image
  has_rich_text :content
  enum :section, [ :homepage_hero_banner, :about_us, :contact_us, :privacy_policy, :terms_of_use ]

  validates :title, :subheadline, :section, presence: true
  validates :image, presence: true, if: -> { self.section == "homepage_hero_banner" }
  validates :content, presence: true, unless: -> { self.section == "homepage_hero_banner" }
  validates :latitude, :longitude, numericality: true, presence: true, if: -> { self.section == "contact_us" }
end
