# frozen_string_literal: true

class MainContactUs < ActiveRecord::Migration[8.0]
  def up
    page = Page.new(
      title: "Contact Us",
      subheadline: "Have questions or need assistance? We're here to help!",
      latitude: 11.034104321018695,
      longitude: 124.59319477599338,
      section: 2
    )

    page.content = <<~HTML
      <h2>Get in Touch</h2>
        <div class="contact-info">
          <h4>Barangay Health Center</h4>
          <br />
          <p>
            <i class="bi bi-geo-alt-fill"></i> Barangay Bagong Buhay, Tondo<br />
            Baong Buhay, Ormoc City, 6541<br />
            Philippines
          </p>
          <br />
          <p>
            <i class="bi bi-telephone-fill"></i> (02) 123-4567 (Landline)<br />
            <i class="bi bi-phone-fill"></i> +63 912 345 6789 (Mobile)
          </p>
          <br />
          <p>
            <i class="bi bi-envelope-fill"></i> junjunpojr@gmail.com
          </p>
        </div>

        <h4>Emergency Contacts</h4>
        <br />
        <div class="">
          <p class="mb-1 text-warning">
            <strong>Emergency Hotline:</strong> 911
          </p>
          <p class="mb-1 text-warning">
            <strong>Local Police:</strong> 117 or (02) 987-6543
          </p>
          <p class="mb-1 text-warning">
            <strong>Nearest Hospital:</strong> (02) 765-4321
          </p>
        </div>
    HTML

    page.save
  end

  def down
    page = Page.find_by(barangay_id: nil, title: "Contact Us")
    page.destroy if page
  end
end
