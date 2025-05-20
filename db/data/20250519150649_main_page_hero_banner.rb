# frozen_string_literal: true

class MainPageHeroBanner < ActiveRecord::Migration[8.0]
  def up
    title = "Welcome to Barangay Health Center"
    subheadline = "We provide essential healthcare services to our community. Visit us for free check-ups, vaccinations, and maternal care programs!"

    image_path = Rails.root.join("app/assets/images/hero_banner.png")

    page = Page.new(
      title: title,
      subheadline: subheadline,
      section: 0)

    page.image.attach(
      io: File.open(image_path),
      filename: File.basename(image_path),
      content_type: "image/png"
    )

    page.save
  end

  def down
    page = Page.find_by(barangay_id: nil, title: "Welcome to Barangay Health Center")
    page.destroy if page
  end
end
