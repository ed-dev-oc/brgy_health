# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password123!" }
    public_uid { SecureRandom.uuid }
    first_name { "Juan" }
    middle_name { "Dela" }
    last_name { "Cruz" }
    suffix { nil }
    phone_number { "09171234567" }
    role { 0 }
    association :barangay
    association :subdivision
  end
end
