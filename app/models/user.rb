class User < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :barangay, optional: true
  belongs_to :subdivision, optional: true

  enum :role, [ :super_admin, :admin, :staff, :patient ]

  validates :email, :phone_number, uniqueness: true

  validates :first_name, uniqueness: {
    scope: [ :middle_name, :last_name, :suffix ],
    message: "with this full name already exists"
  }

  validates :first_name, :last_name, :email, :phone_number, :role, presence: true
  validates :barangay_id, :subdivision_id, presence: true, unless: -> { self.role == "super_admin" }
end
