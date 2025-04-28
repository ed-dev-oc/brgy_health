class HealthProgram < ApplicationRecord
  acts_as_tenant(:barangay)
  has_many :announcements, foreign_key: :health_program_id
end
