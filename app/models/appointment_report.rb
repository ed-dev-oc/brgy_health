class AppointmentReport < ApplicationRecord
  self.primary_key = :id

  # Associations
  acts_as_tenant :barangay
  belongs_to :patient, foreign_key: :patient_id, class_name: "User"
  belongs_to :health_worker, foreign_key: :health_worker_id, class_name: "User", optional: true
  belongs_to :announcement, foreign_key: :announcement_id

  enum :status, [
    "pending",
    "approved",
    "completed",
    "rejected",
    "cancelled"
  ]

  # Scopes for common queries
  scope :upcoming, -> { where("scheduled_at > ?", Time.now).order(:scheduled_at) }
  scope :past, -> { where("scheduled_at <= ?", Time.now).order(scheduled_at: :desc) }
  scope :by_status, ->(status) { where(status_text: status) }
  scope :by_barangay, ->(barangay_id) { where(barangay_id: barangay_id) }

  # Make the model read-only
  def readonly?
    true
  end
end
