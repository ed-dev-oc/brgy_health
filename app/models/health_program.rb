class HealthProgram < ApplicationRecord
  has_paper_trail only: [ :name, :description, :status ], save_changes: true
  acts_as_tenant(:barangay)
  has_many :announcements, foreign_key: :health_program_id
  validates :name, :description, presence: true
  enum :status, [ :active, :inactive ]

  validates :name, :description, presence: true
  validates_uniqueness_to_tenant :name
end
