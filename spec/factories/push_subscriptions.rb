# frozen_string_literal: true

FactoryBot.define do
  factory :push_subscription do
    association :user
    endpoint { "https://push.example.com/endpoint" }
    p256dh { SecureRandom.hex(16) }
    auth { SecureRandom.hex(8) }
  end
end
