class HealthProgram < ApplicationRecord
  belongs_to :barangay
  has_many :announcements, foreign_key: :health_program_id
end
