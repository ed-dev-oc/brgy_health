# frozen_string_literal: true

FactoryBot.define do
  factory :appointment_report do
    row_num { 1 }
    association :patient, factory: :user
    association :health_worker, factory: :user
    association :announcement
    barangay_id { announcement.barangay_id }
    public_uid { SecureRandom.uuid }
    scheduled_at { 2.days.from_now }
    status { 0 }
    reason { "Checkup" }
    notes { "N/A" }
    cancel_reason { nil }
    reschedule_reason { nil }
    patient_first_name { patient.first_name }
    patient_middle_name { patient.middle_name }
    patient_last_name { patient.last_name }
    patient_suffix { patient.suffix }
    patient_email { patient.email }
    patient_phone_number { patient.phone_number }
    health_worker_first_name { health_worker.first_name }
    health_worker_middle_name { health_worker.middle_name }
    health_worker_last_name { health_worker.last_name }
    health_worker_suffix { health_worker.suffix }
    health_worker_email { health_worker.email }
    barangay_name { announcement.barangay.name }
    announcement_name { announcement.name }
  end
end
