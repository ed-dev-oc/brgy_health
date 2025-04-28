class HealthProgram < ApplicationRecord
  acts_as_tenant(:barangay)
  has_many :announcements, foreign_key: :health_program_id
  enum status: { active: 0, inactive: 1 }

  validates :name, :description, presence: true
end
