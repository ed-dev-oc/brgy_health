class Announcement < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  acts_as_tenant :barangay
  belongs_to :posted_by, class_name: "User"
  belongs_to :health_program, optional: true
  accepts_nested_attributes_for :health_program, reject_if: :all_blank

  has_many :appointments
  belongs_to :health_program, optional: true
  accepts_nested_attributes_for :health_program, reject_if: :all_blank

  enum :status, [ :draft, :active, :canceled, :completed, :archived ]
  has_rich_text :description

  attribute :start_date, :datetime, default: -> { Time.current.change(hour: 9, minute: 0, second: 0) }
  attribute :end_date, :datetime, default: -> { Time.current.change(hour: 17, minute: 0, second: 0) }
  attribute :open_time, :time, default: -> { Time.zone.parse("09:00") }
  attribute :close_time, :time, default: -> { Time.zone.parse("17:00") }

  validates :name, :description, :start_date, :end_date, :open_time, :close_time, :location, :max_patients, :audience, :status, presence: true
  validates :start_date, comparison: { greater_than_or_equal_to: -> { Time.current }, message: "must be in the future" }
  validates :end_date, comparison: { greater_than: :start_date, message: "must be after the start date" }
  validates :open_time, comparison: { less_than: :close_time, message: "must be before the close time" }
  validates :close_time, comparison: { greater_than: :open_time, message: "must be after the open time" }
  validates :max_patients, numericality: { only_integer: true, greater_than_or_equal_to: 1, message: "must be a positive whole number" }

  def self.ransackable_attributes(auth_object = nil)
    [ "audience", "barangay_id", "close_time", "created_at", "end_date", "id", "location", "max_patients", "name", "open_time", "posted_by_id", "public_uid", "start_date", "status", "updated_at" ]
  end
end
