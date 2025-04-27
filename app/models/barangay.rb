class Barangay < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :subdivisions
  has_many :users
  has_many :health_programs

  enum :subdivision_type, [ :both, :purok, :zone ]
  validates :name, :region, :province, :city, presence: true

  validates :name, uniqueness: { scope: [ :region, :province, :city ] }
end
