class Appointment < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  belongs_to :barangay
  belongs_to :announcement
  belongs_to :health_worker, optional: true, foreign_key: :health_worker_id, class_name: "User"
  belongs_to :patient, foreign_key: :patient_id, class_name: "User"
  belongs_to :follow_up, foreign_key: :follow_up_id, class_name: "Appointment", optional: true
  acts_as_taggable_on :flags

  attribute :scheduled_at, :datetime, default: -> { Time.current.change(hour: 9, minute: 0, second: 0) }

  validates :scheduled_at, presence: true

  after_create :set_flags
  after_update :completed_appointment

  def self.ransackable_attributes(auth_object = nil)
    [ "announcement_id", "barangay_id", "created_at", "follow_up_id", "health_worker_id", "id", "notes", "patient_id", "public_uid", "reason", "scheduled_at", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "announcement", "barangay", "base_tags", "flag_taggings", "flags", "follow_up", "health_worker", "patient", "taggings" ]
  end

  private

  def set_flags
    self.flag_list.add("pending")
    self.save
  end

  def missed_appointment
    # NOTE: Use this method to background job
    if self.scheduled_at < Time.now
      self.flag_list.remove("pending")
      self.flag_list.add("missed")
      self.save
    end
  end

  def completed_appointment
    if saved_change_to_attribute?(:notes)
      self.flag_list.remove("pending")
      self.flag_list.add("completed")
      self.save
    end
  end
end
