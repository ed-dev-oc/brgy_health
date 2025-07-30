# frozen_string_literal: true

FactoryBot.define do
  factory :testimonial do
    association :barangay
    association :user
    data { "Great service!" }
    rating { 5 }
    status { 0 }
  end
end
