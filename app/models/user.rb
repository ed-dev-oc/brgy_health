class User < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  before_update :prevent_super_admin_demotion
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  acts_as_tenant :barangay, optional: true
  has_one_attached :profile

  belongs_to :barangay, optional: true
  belongs_to :subdivision, optional: true
  has_many :announcements, foreign_key: :posted_by_id
  has_many :appointments, foreign_key: :patient_id
  has_many :appointments_as_health_worker, foreign_key: :health_worker_id, class_name: "Appointment"
  has_many :notifications, as: :recipient, class_name: "Noticed::Notification"
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :about_me_notifications, through: :noticed_events, source: :notifications, class_name: "Noticed::Notification"
  has_many :push_subscriptions
  has_one :testimonial

  acts_as_taggable_on :flags

  accepts_nested_attributes_for :barangay

  enum :role, [ :super_admin, :admin, :staff, :patient ]

  validates :email, :public_uid, uniqueness: true
  validates :phone_number, uniqueness: true, allow_blank: true

  validates :first_name, uniqueness: {
    scope: [ :middle_name, :last_name, :suffix ],
    message: "with this full name already exists"
  }

  validates :first_name, :last_name, :email, :role, presence: true
  validates :barangay, presence: true, unless: -> { self.role == "super_admin" }
  # validate :barangay_already_have_admin, if: -> { self.role == "admin" }

  before_create :add_admin_flag_require_validation, if: -> { self.role == "admin" }
  before_create :add_requirements_flags
  before_update :remove_requirements_flags
  after_create :send_registration_verification_email,
    :send_notification_to_super_admin, if: -> { self.role == "admin" }

  after_update :notify_user_of_credential_change, if: :credentials_changed?

  def self.ransackable_attributes(auth_object = nil)
    [ "barangay_id", "created_at", "email", "encrypted_password", "first_name", "id", "last_name", "middle_name", "phone_number", "public_uid", "remember_created_at", "reset_password_sent_at", "reset_password_token", "role", "subdivision_id", "suffix", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[barangay subdivision]
  end

  def full_name
    "#{self.first_name} #{self.middle_name} #{self.last_name} #{self.suffix}".strip
  end

  def notification_channel
    "user_#{self.public_uid}_notification"
  end

  def full_name
    [first_name, last_name].compact.join(" ")
  end

  private

  def add_requirements_flags
    if self.role != "super_admin"
      self.flag_list.add("no_subdivision") if self.subdivision.nil?
    end

    self.flag_list.add("no_phone_number") if self.phone_number.nil?
    # self.flag_list.add("no_profile") unless self.profile.attached?
  end

  def remove_requirements_flags
    self.flag_list.remove("no_subdivision") if self.subdivision_id.present?
    self.flag_list.remove("no_phone_number") if self.phone_number.present?
    # self.flag_list.remove("no_profile") if self.profile.attached?
  end

  def add_admin_flag_require_validation
    self.flag_list.add("require_validation")
  end

  def send_registration_verification_email
    UserMailer.admin_require_verify_email(self).deliver_later
  end

  def send_notification_to_super_admin
    super_admin = User.super_admin.first

    NewAdminNotifier.with(record: self).deliver(super_admin)
  end

  def prevent_super_admin_demotion
    if role_changed? && role_was == "super_admin"
      errors.add(:role, "cannot be changed for super admin")
      throw(:abort)
    end
  end

 def credentials_changed?
    changed_fields = %w[
      email encrypted_password
      first_name middle_name last_name suffix subdivision_id
    ]
    (changed_fields & saved_changes.keys).any? && (patient? || staff?)
 end

  def notify_user_of_credential_change
    changed_fields = []
    changed_fields << "email" if saved_change_to_email?
    changed_fields << "password" if saved_change_to_encrypted_password?
    changed_fields << "first_name" if saved_change_to_first_name?
    changed_fields << "middle_name" if saved_change_to_middle_name?
    changed_fields << "last_name" if saved_change_to_last_name?
    changed_fields << "suffix" if saved_change_to_suffix?
    changed_fields << "subdivision" if saved_change_to_subdivision_id?

    UserCredentialChangedNotifier.with(
      changed_attributes: changed_fields
    ).deliver_later(self)
  end
end
