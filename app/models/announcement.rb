class Announcement < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  acts_as_tenant :barangay
  belongs_to :posted_by, class_name: "User"
  belongs_to :health_program, optional: true
  accepts_nested_attributes_for :health_program, reject_if: :all_blank

  has_many :appointments
  has_many :activity_logs, as: :loggable, dependent: :destroy
  belongs_to :health_program, optional: true
  accepts_nested_attributes_for :health_program, reject_if: :all_blank

  enum :status, [ :draft, :active, :canceled, :completed, :archived ]
  has_rich_text :description
  has_many_attached :images

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
  validate :images_presence, on: :create

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

  def generate_change_log_description
  return unless saved_changes.any?

  messages = []

  saved_changes.except(:updated_at).each do |attr, (old_val, new_val)|
    case attr
    when "status"
      messages << "📢 Status changed from <strong>#{old_val}</strong> to <strong>#{new_val}</strong>"
    when "name"
      messages << "📝 Title updated from <code>#{old_val}</code> to <code>#{new_val}</code>"
    when "location"
      messages << "📍 Location changed from <code>#{old_val}</code> to <code>#{new_val}</code>"
    when "start_date", "end_date"
      messages << "📅 Schedule updated" unless messages.include?("📅 Schedule updated")
    when "open_time", "close_time"
      messages << "⏰ Time changed" unless messages.include?("⏰ Time changed")
    when "audience"
      messages << "👥 Audience changed from <code>#{old_val}</code> to <code>#{new_val}</code>"
    when "max_patients"
      messages << "👤 Max patients updated from <code>#{old_val}</code> to <code>#{new_val}</code>"
    when "health_program_id"
      old_program = HealthProgram.find_by(id: old_val)&.name || "None"
      new_program = HealthProgram.find_by(id: new_val)&.name || "None"
      messages << "🩺 Health program changed from <strong>#{old_program}</strong> to <strong>#{new_program}</strong>"
    else
      messages << "🔧 #{attr.humanize} changed"
    end
  end

  messages.any? ? messages.join("<br>") : "No changes detected."
end


  private

  def images_presence
    errors.add(:images, "must have at least one image") if images.empty?
  end
end
