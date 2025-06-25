class Announcement < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  has_paper_trail save_changes: true
  acts_as_tenant :barangay
  belongs_to :posted_by, class_name: "User"
  belongs_to :health_program, optional: true
  accepts_nested_attributes_for :health_program, reject_if: :all_blank

  has_many :appointments
  has_rich_text :description
  has_many_attached :images

  enum :status, [ :draft, :active, :canceled, :completed, :archived ]

  attribute :start_date, :datetime, default: -> { Time.current.change(hour: 9, minute: 0, second: 0) }
  attribute :end_date, :datetime, default: -> { Time.current.change(hour: 17, minute: 0, second: 0) }
  attribute :open_time, :time, default: -> { Time.zone.parse("09:00") }
  attribute :close_time, :time, default: -> { Time.zone.parse("17:00") }

  validates :name, :description, :start_date, :end_date, :open_time, :close_time, :location, :max_patients, :audience, :status, presence: true
  validates :start_date, comparison: { greater_than_or_equal_to: -> { Time.current }, message: "must be in the future" }, on: :create
  validates :end_date, comparison: { greater_than: :start_date, message: "must be after the start date" }
  validates :open_time, comparison: { less_than: :close_time, message: "must be before the close time" }
  validates :close_time, comparison: { greater_than: :open_time, message: "must be after the open time" }
  validates :max_patients, numericality: { only_integer: true, greater_than_or_equal_to: 1, message: "must be a positive whole number" }
  validate :images_presence, on: :create

  after_save :track_rich_text_description_change

  def self.ransackable_attributes(auth_object = nil)
    [ "audience", "barangay_id", "close_time", "created_at", "end_date", "id", "location", "max_patients", "name", "open_time", "posted_by_id", "public_uid", "start_date", "status", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "appointments", "barangay", "health_program", "images_attachments", "images_blobs", "posted_by", "rich_text_description" ]
  end

  ransacker :full_name do |parent|
    Arel::Nodes::NamedFunction.new("CONCAT_WS", [
      " ", parent.table[:first_name], parent.table[:middle_name], parent.table[:last_name]
    ])
  end

  def capacity_percentage
    (appointments.approved.count.to_f / max_patients) * 100
  end

  def appointment_full?
    appointments.approved.count >= max_patients
  end

  def approved_patients_count
    appointments.approved.count
  end

  def pending_patients_count
    appointments.pending.count
  end

  def canceled_patients_count
    appointments.cancelled.count
  end

  def today_appointments_count
    appointments.approved.where(scheduled_at: Time.zone.today.all_day).count
  end

  private

  def images_presence
    errors.add(:images, "must have at least one image") if images.empty?
  end

  def track_rich_text_description_change
    if previous_changes.blank? && description.saved_change_to_body?
      PaperTrail.request(enabled: true) do
        PaperTrail::Version.create!(
          item: self,
          event: 'update',
          whodunnit: PaperTrail.request.whodunnit,
          object_changes: {
            description: [description.saved_change_to_body&.first.to_s, description.saved_change_to_body&.last.to_s]
          }.to_yaml
        )
      end
    end
  end
end
