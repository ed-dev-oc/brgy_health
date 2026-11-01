class BarangayGeneratePagesJob < ApplicationJob
  queue_as :default

  def perform(barangay_id)
    @barangay = Barangay.find(barangay_id)
    raise "Barangay not found" unless @barangay

    generate_homepage_hero_banner
    generate_about_us
    generate_contact_us
  end

  private

  def generate_homepage_hero_banner
    title = "Welcome to Barangay Health Center"
    subheadline = "We provide essential healthcare services to our community. Visit us for free check-ups, vaccinations, and maternal care programs!"

    image_path = Rails.root.join("app/assets/images/hero_banner.png")

    page = Page.new(
      barangay: @barangay,
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

  def generate_about_us
    page = Page.new(
      barangay: @barangay,
      title: "About Our Barangay Health Center",
      subheadline: "Learn more about our mission and vision.",
      section: 1)

    cms_path = Rails.application.routes.url_helpers.admin_cms_url(subdomain: @barangay.subdomain)

    page.content = <<~HTML
      <h1>Update the Section to this <a href="#{ cms_path }"><strong>page</strong></a>.</h1>
    HTML

    page.save
  end

  def generate_contact_us
    page = Page.new(
      barangay: @barangay,
      title: "Contact Us",
      subheadline: "Have questions or need assistance? We're here to help!",
      latitude: 14.5995,
      longitude: 120.9842,
      section: 2)

    cms_path = Rails.application.routes.url_helpers.admin_cms_url(subdomain: @barangay.subdomain)

    page.content = <<~HTML
      <h1>Update the Section to this <a href="#{ cms_path }"><strong>page</strong></a>.</h1>
    HTML

    page.save
  end
end
