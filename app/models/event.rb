class Event < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  has_paper_trail save_changes: true
  acts_as_tenant :barangay
  belongs_to :posted_by, class_name: "User"
  has_rich_text :description
  has_many_attached :images
  has_many :views, class_name: "EventView", dependent: :destroy

  enum :audience, [
    :all_residents,
    :barangay_officials,
    :senior_citizens,
    :pregnant_women,
    :children,
    :adolescents,
    :pwds,
    :mothers,
    :fathers,
    :families
  ]
  enum :status, [ :draft, :active, :completed, :archived ]
  attribute :start_date, :datetime, default: -> { Time.current.change(hour: 9, minute: 0, second: 0) }
  attribute :end_date, :datetime, default: -> { Time.current.change(hour: 17, minute: 0, second: 0) }

  validates :name, :location, :start_date, :end_date, :description, presence: true
  validate :images_presence, on: :create

  before_save :update_image_timestamp, if: :should_update_image_timestamp?
  after_create :send_patient_notification

  ransacker :full_name do |parent|
    Arel::Nodes::NamedFunction.new("CONCAT_WS", [
      " ", parent.table[:first_name], parent.table[:middle_name], parent.table[:last_name]
    ])
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "audience", "barangay_id", "created_at", "end_date", "id", "location", "name", "posted_by_id", "public_uid", "start_date", "status", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "barangay", "images_attachments", "images_blobs", "posted_by", "rich_text_description" ]
  end

  private

  def images_presence
    errors.add(:images, "must have at least one image") if images.empty?
  end

  def send_patient_notification
    patients = self.barangay.users.patient

    NewEventNotifier.with(record: self).deliver(patients)
  end

  def should_update_image_timestamp?
  images.attachments.any?(&:new_record?)
  end

  def update_image_timestamp
    self.image_updated_at = Time.current
  end
end
