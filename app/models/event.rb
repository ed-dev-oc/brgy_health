class Event < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::NumberRandom.new

  acts_as_tenant :barangay
  belongs_to :posted_by, class_name: "User"
  has_rich_text :description

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
end
