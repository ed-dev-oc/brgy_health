# frozen_string_literal: true

FactoryBot.define do
  factory :health_program do
    association :barangay
    sequence(:name) { |n| "Immunization #{n}" }
    description { "Routine immunization program" }
    status { 0 }
  end
end
