class Page < ApplicationRecord
  acts_as_tenant :barangay, optional: true

  has_paper_trail save_changes: true

  has_one_attached :image
  has_rich_text :content

  enum :section, [:homepage_hero_banner, :about_us, :contact_us, :privacy_policy, :terms_of_use]

  validates :title, :subheadline, :section, presence: true
  validates :image, presence: true, if: -> { section == "homepage_hero_banner" }
  validates :content, presence: true, unless: -> { section == "homepage_hero_banner" }
  validates :latitude, :longitude, numericality: true, presence: true, if: -> { section == "contact_us" }

  before_save :update_image_timestamp, if: :should_update_image_timestamp?

  private

  def should_update_image_timestamp?
    image.attached? && (image.attachment.new_record? || image.blob.new_record?)
  end

  def update_image_timestamp
    self.image_updated_at = Time.current
  end
end
