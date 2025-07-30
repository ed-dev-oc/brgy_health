# frozen_string_literal: true

FactoryBot.define do
  factory :subdivision do
    association :barangay
    sequence(:name) { |n| "Subdivision #{n}" }
    slug { |s| s.name.parameterize }
  end
end
