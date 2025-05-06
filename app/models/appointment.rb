class Appointment < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  acts_as_tenant :barangay
  belongs_to :announcement
  belongs_to :health_worker, optional: true, foreign_key: :health_worker_id, class_name: "User"
  belongs_to :patient, foreign_key: :patient_id, class_name: "User"
  belongs_to :follow_up, class_name: "Appointment", foreign_key: "follow_up_id", optional: true
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"

  has_one :parent_appointment,
             class_name: "Appointment",
             foreign_key: "follow_up_id",
             dependent: :nullify,
             inverse_of: :follow_up

  acts_as_taggable_on :flags # FollowUpCheckUp, Missed
  enum :status, [ :pending, :approved, :completed, :rejected, :cancelled ]

  attribute :scheduled_at, :datetime, default: -> { Time.current.change(hour: 9, minute: 0, second: 0) }

  validates :scheduled_at, presence: true
  after_update :completed_appointment
  after_create :send_admin_and_staff_notification
  after_update :send_notification_status_changed

  def self.ransackable_attributes(auth_object = nil)
    [ "announcement_id", "barangay_id", "created_at", "follow_up_id", "health_worker_id", "id", "notes", "patient_id", "public_uid", "reason", "scheduled_at", "updated_at", "status" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "announcement", "barangay", "base_tags", "flag_taggings", "flags", "follow_up", "health_worker", "patient", "taggings" ]
  end

  def has_parent_appointment?
    parent_appointment.present?
  end

  private

  def missed_appointment
    # NOTE: Use this method to background job
    if self.scheduled_at < Time.now && self.approved?
      self.flag_list.add("missed")
      self.save
    end
  end

  def completed_appointment
    if saved_change_to_attribute?(:notes) && self.approved?
      self.completed!
    end
  end

  def send_admin_and_staff_notification
    NewAppointmentNotifier.with(record: self).deliver(self.barangay.admin_and_staff)
  end

  def send_notification_status_changed
    puts("Ed Gwapo")
    if saved_change_to_status?
      puts("Ed Gwapo 1")
      users = self.cancelled? ? self.barangay.admin_and_staff : self.patient

      AppointmentStatusChangedNotifier.with(record: self).deliver(users)
    end
  end
end
