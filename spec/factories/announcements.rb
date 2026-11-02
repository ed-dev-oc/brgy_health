# frozen_string_literal: true

FactoryBot.define do
  factory :announcement do
    public_uid { SecureRandom.uuid }
    association :barangay
    association :posted_by, factory: :user
    association :health_program
    name { "Sample Announcement" }
    description { "This is a sample announcement." }
    start_date { 1.day.from_now }
    end_date { 2.days.from_now }
    open_time { "08:00" }
    close_time { "17:00" }
    location { "Barangay Hall" }
    max_patients { 100 }
    audience { "public" }
    status { 0 }
    after(:build) do |announcement|
      announcement.images.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/sample.jpeg')),
        filename: 'sample.jpeg',
        content_type: 'image/jpeg'
      ) if announcement.images.blank?
    end
  end
end
