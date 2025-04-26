class User < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :barangay, optional: true
  belongs_to :subdivision, optional: true
  acts_as_taggable_on :flags

  enum :role, [ :super_admin, :admin, :staff, :patient ]

  validates :email, :phone_number, :public_uid, uniqueness: true

  validates :first_name, uniqueness: {
    scope: [ :middle_name, :last_name, :suffix ],
    message: "with this full name already exists"
  }

  validates :first_name, :last_name, :email, :role, presence: true
  validates :barangay_id, presence: true, unless: -> { self.role == "super_admin" }

  before_create :add_flag_require_validation, if: -> { self.role == "admin" }
  after_validation :add_flags

  private

  def add_flags
    if self.role != "super_admin"
      self.flag_list.add("no_subdivision") if self.subdivision.nil?
    end

    self.flag_list.add("no_phone_number") if self.phone_number.nil?
    # self.flag_list.add("no_profile") if self.profile.attached?
  end

  def add_flag_require_validation
    self.flag_list.add("require_validation")
  end
end
