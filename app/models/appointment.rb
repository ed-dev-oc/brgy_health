class Appointment < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  has_paper_trail save_changes: true
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

  acts_as_taggable_on :flags # FollowUpCheckUp, Missed, Rescheduled, Waitlisted
  enum :status, [ :pending, :approved, :completed, :rejected, :cancelled ]
  VALID_FOR_RESCHEDULE_STATUS = [ :pending, :approved ].freeze
  VALID_FOR_CANCELLATION_STATUS = [ :pending, :approved ].freeze
  ADMIN_VALID_FOR_APPROVE_AND_REJECTED_STATUS = [ :pending ].freeze
  ADMIN_VALID_FOR_CANCELLATION_STATUS = [ :approved ].freeze

  attribute :scheduled_at, :datetime, default: -> { Time.current.change(hour: 9, minute: 0, second: 0) }

  validates :scheduled_at, presence: true
  validates :cancel_reason, presence: true, if: :cancelled?
  validates :reschedule_reason, presence: true, if: -> { self.flag_list.include?("reschedule") }
  validate :scheduled_at_within_announcement_range

  after_update :completed_appointment
  after_create :send_admin_and_staff_notification
  after_update :send_notification_status_changed
  after_update :send_follow_up_check_up_notification
  after_update :reminder_notification_job

  def self.ransackable_attributes(auth_object = nil)
    [ "announcement_id", "barangay_id", "created_at", "follow_up_id", "health_worker_id", "id", "notes", "patient_id", "public_uid", "reason", "scheduled_at", "updated_at", "status" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "announcement", "barangay", "base_tags", "flag_taggings", "flags", "follow_up", "health_worker", "patient", "taggings" ]
  end

  def has_parent_appointment?
    parent_appointment.present?
  end

  def appointment_reminder_job_wait_until_condition
    if Time.now < self.scheduled_at - 24.hours
      self.scheduled_at - 24.hours
    elsif Time.now < self.scheduled_at - 60.minutes
      self.scheduled_at - 60.minutes
    elsif Time.now < self.scheduled_at - 30.minutes
      self.scheduled_at - 30.minutes
    elsif Time.now < self.scheduled_at - 5.minutes
      self.scheduled_at - 5.minutes
    end
  end

  private

  def completed_appointment
    if saved_change_to_attribute?(:notes) && self.approved?
      self.completed!
    end
  end

  def send_admin_and_staff_notification
    NewAppointmentNotifier.with(record: self).deliver(self.barangay.admin_and_staff)
  end

  def send_notification_status_changed
    if saved_change_to_status?
      users = (self.barangay.admin_and_staff.to_a + [ self.patient ]).uniq

      AppointmentStatusChangedNotifier.with(record: self).deliver(users)
    end
  end

  def send_follow_up_check_up_notification
    if self.flag_list.include?("follow_up_check_up")
      FollowUpCheckUpNotifier.with(record: self).deliver(self.patient)
    end
  end

  def scheduled_at_within_announcement_range
    return if scheduled_at.blank?

    unless scheduled_at.between?(announcement.start_date, announcement.end_date)
      errors.add(:scheduled_at, "must be during the announcement's time range (#{announcement.start_date.strftime("%B %e, %Y")} to #{announcement.end_date.strftime("%B %e, %Y")})")
    end
  end

  def reminder_notification_job
    if saved_change_to_attribute?(:scheduled_at)
      if self.reminder_job_id.present?
        SolidQueue::Job.find_by(active_job_id: self.reminder_job_id)&.discard
      end

      wait_until = appointment_reminder_job_wait_until_condition

      if wait_until
        job = AppointmentReminderJob.set(wait_until: wait_until).perform_later(self.id)

        if job.respond_to?(:job_id)
          self.update_columns(reminder_job_id: job.job_id)
        end
      end
    end
  end
end
