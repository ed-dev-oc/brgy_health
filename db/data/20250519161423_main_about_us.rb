# frozen_string_literal: true

class MainAboutUs < ActiveRecord::Migration[8.0]
  def up
    page = Page.new(
      title: "About Our Barangay Health Center",
      subheadline: "Learn more about our mission and vision.",
      section: 1)

    page.content = <<~HTML
      <div class="col-lg-8 mx-auto">
        <div class="terms-section">
          <h2 style="font-size: 32px;" class="mb-3">Our Mission</h2>
          <p style="font-size: 16px;" class="mb-4">To deliver accessible, affordable, and quality healthcare services to all residents of our barangay, promoting wellness and preventing diseases through education and community involvement.</p>
        </div>
        <div class="terms-section" style="font-size: 16px;">
          <h2 style="font-size: 32px;" class="pb-0 mb-3"><br>Our Vision</h2>
          <p style="font-size: 16px;">A healthy and empowered community where every resident has access to basic healthcare services and health education, leading to improved quality of life.</p>
          <ul></ul>
        </div>
        <div class="terms-section">
          <h2 style="font-size: 32px;" class="mb-3"><br>Our Services</h2>
          <p style="font-size: 16px;">1. Basic medical consultations<br>2. Maternal and child health services<br>3. Immunization programs<br>4. Family planning services<br>5. Health education and promotion<br>6. First aid and emergency care<br>7. TB-DOTS program</p>
        </div>
        <div class="terms-section">
          <h2 style="font-size: 32px;" class="pt-0 mt-4 mb-3"><br>Our Team</h2>
          <p style="font-size: 16px;">Our health center is staffed by dedicated healthcare professionals including barangay health workers, nurses, midwives, and a municipal health officer who visits regularly. We work in partnership with the local government unit and the Department of Health to ensure quality service delivery.</p>
        </div>
        <div class="terms-section">
          <h2 style="font-size: 32px;" class="pt-3 mb-3">Patient Responsibilities</h2>
          <p style="font-size: 16px;">As a patient, you agree to:</p>
          <ul>
            <li style="font-size: 16px;">1. Provide accurate and complete health information</li>
            <li style="font-size: 16px;">2. Follow healthcare providers' instructions and treatment plans</li>
            <li style="font-size: 16px;">3. Treat staff and other patients with respect</li>
            <li style="font-size: 16px;">4. Maintain appropriate behavior in the health center</li>
            <li style="font-size: 16px;">5. Pay any required fees for specific services (if applicable)</li>
          </ul>
        </div>
        <div class="terms-section">
          <h2 style="font-size: 32px;" class="pt-3 mb-3"><br>Health Center Hours</h2>
          <p style="font-size: 16px;"><strong>Monday to Friday:</strong>&nbsp;8:00 AM - 5:00 PM<br><strong>Saturday:</strong>&nbsp;8:00 AM - 12:00 PM<br><strong>Sunday:</strong>&nbsp;Closed (Emergency services available)</p>
          <ul></ul>
        </div>
      </div>
    HTML

    page.save
  end

  def down
    page = Page.find_by(barangay_id: nil, title: "About Our Barangay Health Center")
    page.destroy if page
  end
end
