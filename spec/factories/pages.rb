# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    association :barangay
    title { "About Us" }
    subheadline { "Welcome to our barangay" }
    section { "homepage_hero_banner" }
    latitude { 14.174 }
    longitude { 121.243 }
    after(:build) do |page|
      page.image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/sample.jpeg')),
        filename: 'sample.jpeg',
        content_type: 'image/jpeg'
      ) if page.image.blank?
    end
  end
end
