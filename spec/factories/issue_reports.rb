# frozen_string_literal: true

FactoryBot.define do
  factory :issue_report do
    issue_type { 0 }
    title { "Sample Issue" }
    description { "There is a problem." }
    priority { 1 }
    module_area { 0 }
    url { "http://example.com" }
    email { "user@example.com" }
    status { 0 }
    public_uid { SecureRandom.uuid }
    after(:build) do |issue_report|
      issue_report.images.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/sample.jpeg')),
        filename: 'sample.jpeg',
        content_type: 'image/jpeg'
      ) if issue_report.images.blank?
    end
  end
end
