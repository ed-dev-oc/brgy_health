# frozen_string_literal: true

FactoryBot.define do
  factory :barangay do
    sequence(:name) { |n| "Barangay #{n}" }
    slug { |b| b.name.parameterize }
    subdivision_type { 0 }
    region { "Region IV-A" }
    province { "Laguna" }
    city { "Calamba" }
    subdomain { |b| b.name.parameterize }
  end
end
