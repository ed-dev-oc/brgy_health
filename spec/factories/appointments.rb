# frozen_string_literal: true

FactoryBot.define do
  factory :appointment do
    public_uid { SecureRandom.uuid }
    association :barangay
    association :announcement
    association :health_worker, factory: :user
    association :patient, factory: :user
    scheduled_at { announcement&.start_date ? announcement.start_date + 1.hour : 2.days.from_now }
    reason { "Checkup" }
    notes { "N/A" }
    follow_up_id { nil }
    status { 0 }
    cancel_reason { nil }
    reschedule_reason { nil }
    reminder_job_id { SecureRandom.hex(8) }
  end
end
