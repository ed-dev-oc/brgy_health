# frozen_string_literal: true

class MainPrivacyPolicy < ActiveRecord::Migration[8.0]
  def up
    page = Page.new(
      name: "Privacy Policy",
      title: "Privacy Policy",
      subheadline: "How we protect and handle your personal information",
      section: 3
    )

    page.content = <<~HTML
      <h2>Introduction</h2>
      <p>The Barangay Health Center is committed to protecting the privacy and security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our health center or use our services.</p>

      <h2>Information We Collect</h2>
      <p>We may collect the following types of information:</p>
      <ul>
          <li><strong>Personal Identification Information:</strong> Name, address, birth date, gender, contact details</li>
          <li><strong>Health Information:</strong> Medical history, current health conditions, treatments, medications</li>
          <li><strong>Demographic Information:</strong> Age, marital status, family composition</li>
          <li><strong>Service Usage Data:</strong> Records of services accessed, appointments, consultations</li>
      </ul>

      <h2>How We Use Your Information</h2>
      <p>We use your personal information for the following purposes:</p>
      <ul>
          <li>To provide healthcare services and treatment</li>
          <li>To maintain accurate medical records</li>
          <li>To communicate with you about appointments and health programs</li>
          <li>To comply with legal and regulatory requirements</li>
          <li>To improve our services and health programs</li>
          <li>For public health monitoring and reporting (in anonymized form when possible)</li>
      </ul>

      <h2>Data Protection</h2>
      <p>We implement appropriate security measures to protect your personal information:</p>
      <ul>
          <li>Physical records are stored in secure cabinets with restricted access</li>
          <li>Electronic records are protected with password security and encryption</li>
          <li>Staff are trained on data privacy and confidentiality</li>
          <li>We comply with the Philippine Data Privacy Act of 2012 (RA 10173)</li>
      </ul>

      <h2>Sharing of Information</h2>
      <p>We may share your information only in these circumstances:</p>
      <ul>
          <li>With other healthcare providers when necessary for your treatment</li>
          <li>When required by law (e.g., reportable diseases, court orders)</li>
          <li>With government health agencies for public health programs (usually anonymized)</li>
          <li>With your explicit consent for other specific purposes</li>
      </ul>

      <h2>Your Rights</h2>
      <p>Under the Data Privacy Act, you have the right to:</p>
      <ul>
          <li>Access your personal and health information</li>
          <li>Request correction of inaccurate or incomplete data</li>
          <li>Request restriction of processing in certain circumstances</li>
          <li>Withdraw consent for uses beyond primary healthcare purposes</li>
          <li>Lodge complaints with the National Privacy Commission</li>
      </ul>

      <h2>Changes to This Policy</h2>
      <p>We may update this Privacy Policy from time to time. The current version will always be posted on our website and available at our health center.</p>

      <h2>Contact Us</h2>
      <p>If you have questions about this Privacy Policy or your personal data, please contact our Data Protection Officer at:</p>
      <address>
          Barangay Health Center<br>
          Barangay Bagong Buhay, Ormoc City, 6541<br>
          Email: junjunpojr@gmail<br>
          Phone: (02) 123-4567
      </address>

      <p><strong>Effective Date:</strong> This policy is effective as of January 1, 2025.</p>
    HTML

    page.save
  end

  def down
    page = Page.find_by(barangay_id: nil, name: "Privacy Policy")
    page.destroy if page
  end
end
