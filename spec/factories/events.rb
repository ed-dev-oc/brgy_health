# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    public_uid { SecureRandom.uuid }
    association :barangay
    association :posted_by, factory: :user
    name { "Sample Event" }
    description { "This is a sample event." }
    start_date { 2.days.from_now }
    end_date { 3.days.from_now }
    audience { 0 }
    location { "Barangay Hall" }
    status { 0 }
    after(:build) do |event|
      event.images.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/sample.jpeg')),
        filename: 'sample.jpeg',
        content_type: 'image/jpeg'
      ) if event.images.blank?
    end
  end
end
