# frozen_string_literal: true

class MainTermsOfUse < ActiveRecord::Migration[8.0]
  def up
    page = Page.new(
      title: "Terms of Use",
      subheadline: "Rules and guidelines for using our services and website",
      section: 4
    )

    page.content = <<~HTML
      <h2>Acceptance of Terms</h2>
      <p>By accessing or using the Barangay Health Center's services, website, or facilities, you agree to comply with and be bound by these Terms of Use. If you do not agree with these terms, please do not use our services.</p>
      <br/>
      <h2>Services Provided</h2>
      <p>The Barangay Health Center provides basic healthcare services to residents of our barangay, including but not limited to:</p>
      <ul>
        <li>Medical consultations</li>
        <li>Maternal and child health services</li>
        <li>Immunization programs</li>
        <li>Health education and promotion</li>
        <li>First aid and emergency care</li>
      </ul>
      <p>Services are provided during regular operating hours unless otherwise specified.</p>
      <br/>
      <h2>Eligibility</h2>
      <p>Primary services are available to all registered residents of our barangay. Non-residents may be served for emergency cases or as capacity allows.</p>
      <br/>
      <h2>Appointments</h2>
      <ul>
        <li>Appointments are recommended but not always required for basic services</li>
        <li>Walk-ins will be accommodated based on availability</li>
        <li>Please arrive on time for your appointment</li>
        <li>Cancel or reschedule appointments with at least 24 hours notice when possible</li>
      </ul>
      <br/>
      <h2>Patient Responsibilities</h2>
      <p>As a patient, you agree to:</p>
      <ul>
        <li>Provide accurate and complete health information</li>
        <li>Follow healthcare providers' instructions and treatment plans</li>
        <li>Treat staff and other patients with respect</li>
        <li>Maintain appropriate behavior in the health center</li>
        <li>Pay any required fees for specific services (if applicable)</li>
      </ul>
      <br/>
      <h2>Website Use</h2>
      <p>When using our website, you agree not to:</p>
      <ul>
        <li>Use the site for any unlawful purpose</li>
        <li>Attempt to gain unauthorized access to our systems</li>
        <li>Post or transmit harmful or offensive content</li>
        <li>Use the site in a way that could damage or impair its functionality</li>
      </ul>
      <br/>
      <h2>Intellectual Property</h2>
      <p>All content on our website, including text, graphics, logos, and images, is the property of the Barangay Health Center or its content suppliers and is protected by copyright laws.</p>
      <br/>
      <h2>Disclaimer of Warranties</h2>
      <p>While we strive to provide accurate health information, the content on our website is for general informational purposes only and should not be considered medical advice. Always consult with a healthcare professional for diagnosis and treatment.</p>
      <br/>
      <h2>Limitation of Liability</h2>
      <p>The Barangay Health Center shall not be liable for any direct, indirect, incidental, or consequential damages resulting from the use of our services or website.</p>
      <br/>
      <h2>Changes to Terms</h2>
      <p>We reserve the right to modify these Terms of Use at any time. Changes will be effective immediately upon posting on our website.</p>
      <br/>
      <h2>Governing Law</h2>
      <p>These Terms of Use shall be governed by and construed in accordance with the laws of the Republic of the Philippines.</p>
      <br/>
      <h2>Contact Information</h2>
      <p>For questions about these Terms of Use, please contact us at:</p>
      <address>
        Barangay Health Center<br>
        Barangay Bagong Buhay, Ormoc City, 6541<br>
        Email: junjunpojr@gmail<br>
        Phone: (02) 123-4567
      </address>
      <br/>
      <p><strong>Effective Date:</strong> These terms are effective as of January 1, 2025.</p>
    HTML

    page.save
  end

  def down
    page = Page.find_by(barangay_id: nil, title: "Terms of Use")
    page.destroy if page
  end
end
