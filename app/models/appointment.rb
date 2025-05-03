class Appointment < ApplicationRecord
  belongs_to :barangay
  belongs_to :announcement
  belongs_to :health_worker, optional: true, foreign_key: :health_worker_id, class_name: "User"
  belongs_to :patient, foreign_key: :patient_id, class_name: "User"
  belongs_to :follow_up, foreign_key: :follow_up_id, class_name: "Appointment", optional: true

  validates :scheduled_at, presence: true
end
