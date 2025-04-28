class Admin::HealthProgram < ApplicationRecord
    belongs_to :barangay
    has_many :announcements
end
