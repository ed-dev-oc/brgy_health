class User < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile

  belongs_to :barangay, optional: true
  belongs_to :subdivision, optional: true
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
end
