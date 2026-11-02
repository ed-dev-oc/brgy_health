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

  has_many :events, foreign_key: "posted_by_id", dependent: :destroy

  acts_as_taggable_on :flags

  accepts_nested_attributes_for :barangay

  enum :role, [ :super_admin, :admin, :staff, :patient, :platform_staff ]

  validates :email, :public_uid, uniqueness: true
  validates :phone_number, uniqueness: true, allow_blank: true

  validates :first_name, uniqueness: {
    scope: [ :middle_name, :last_name, :suffix ],
    message: "with this full name already exists"
  }

  validates :first_name, :last_name, :email, :role, presence: true
  validates :barangay, presence: true, unless: -> { self.platform_user? }
  validate :ensure_at_least_one_active_admin, on: :update
  # validate :barangay_already_have_admin, if: -> { self.role == "admin" }

  before_create :add_admin_flag_require_validation, if: -> { self.role == "admin" }
  before_create :set_default_status
  before_create :add_requirements_flags
  before_update :remove_requirements_flags
  after_create :send_registration_verification_email,
    :send_notification_to_super_admin, if: -> { self.role == "admin" }

  after_update :notify_user_of_credential_change, if: :credentials_changed?

  ransacker :full_name do
    Arel::Nodes::NamedFunction.new(
      "COALESCE",
      [
        Arel::Nodes::NamedFunction.new(
          "CONCAT_WS",
          [
            Arel::Nodes.build_quoted(" "),
            arel_table[:first_name],
            arel_table[:middle_name],
            arel_table[:last_name],
            arel_table[:suffix]
          ]
        ),
        Arel::Nodes.build_quoted("")
      ]
    )
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "full_name", "barangay_id", "created_at", "email", "encrypted_password", "first_name", "id", "last_name", "middle_name", "phone_number", "public_uid", "remember_created_at", "reset_password_sent_at", "reset_password_token", "role", "subdivision_id", "suffix", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "about_me_notifications", "announcements", "appointments", "appointments_as_health_worker", "barangay", "base_tags", "events", "flag_taggings", "flags", "noticed_events", "notifications", "push_subscriptions", "subdivision", "taggings", "testimonial" ]
  end

  def full_name
    "#{self.first_name} #{self.middle_name} #{self.last_name} #{self.suffix}".strip
  end

  def notification_channel
    "user_#{self.public_uid}_notification"
  end

  def initials
    "#{self.first_name.first.capitalize}#{self.last_name.first.capitalize}"
  end

  def platform_user?
    super_admin? || platform_staff?
  end

  def active?
    if flag_list.include?("inactive")
      false
    elsif flag_list.include?("active")
      true
    else
      !flag_list.include?("require_validation")
    end
  end

  def active_for_authentication?
    super && !flag_list.include?("inactive")
  end

  def inactive_message
    flag_list.include?("inactive") ? :inactive : super
  end

  def last_active_admin_in_barangay?
    return false unless admin? && barangay_id.present?

    ActsAsTenant.without_tenant do
      other_active_admins = User.where(barangay_id: barangay_id, role: :admin)
                                .where.not(id: id)
                                .select(&:active?)
      other_active_admins.empty?
    end
  end

  private

  def ensure_at_least_one_active_admin
    return unless barangay_id.present? && role_was == "admin"

    is_no_longer_active_admin = (role != "admin") || flag_list.include?("inactive") || !active?

    if is_no_longer_active_admin && last_active_admin_in_barangay?
      errors.add(:base, "Each barangay must have at least one active admin.")
    end
  end

  def set_default_status
    unless flag_list.include?("inactive") || (admin? && flag_list.include?("require_validation"))
      self.flag_list.add("active")
    end
  end

  def add_requirements_flags
    if !self.platform_user?
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
    super_admins = ActsAsTenant.without_tenant { User.where(role: [ :super_admin, :platform_staff ]) }

    super_admins.each do |admin|
      NewAdminNotifier.with(record: self).deliver(admin)
    end
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
    changed_attributes = {}

    {
      "email" => :email,
      "password" => :encrypted_password,
      "first_name" => :first_name,
      "middle_name" => :middle_name,
      "last_name" => :last_name,
      "suffix" => :suffix,
      "subdivision" => :subdivision_id
    }.each do |label, attr|
      if saved_change_to_attribute?(attr)
        old_value, new_value = saved_changes[attr.to_s]
        changed_attributes[label] = {
          from: old_value,
          to: new_value
        }
      end
    end

    UserCredentialChangedNotifier.with(
      record: self,
      changed_attributes: changed_attributes
    ).deliver_later(self)
  end
end
