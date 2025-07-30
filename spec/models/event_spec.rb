require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "associations" do
    it { should belong_to(:posted_by).class_name('User') }
    it { should have_rich_text(:description) }
    it { should have_many_attached(:images) }
  end

  describe "enums" do
    it {
      should define_enum_for(:audience).with_values([
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
      ])
    }
    it {
      should define_enum_for(:status).with_values([ :draft, :active, :completed, :archived ])
    }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:description) }
  end

  describe "custom validations" do
    let(:event) { described_class.new(name: "Test Event", location: "Test Location", start_date: Time.current, end_date: Time.current + 1.hour, description: "desc", posted_by: build_stubbed(:user)) }

    it "is invalid without images on create" do
      event.valid?
      expect(event.errors[:images]).to include("must have at least one image")
    end
  end

  describe "attributes" do
    it "has default start_date at 9:00" do
      event = described_class.new
      expect(event.start_date.hour).to eq(9)
      expect(event.start_date.min).to eq(0)
    end
    it "has default end_date at 17:00" do
      event = described_class.new
      expect(event.end_date.hour).to eq(17)
      expect(event.end_date.min).to eq(0)
    end
  end

  describe "callbacks" do
    it "calls send_patient_notification after create" do
      event = build(:event)
      allow(event).to receive(:send_patient_notification)
      event.save # triggers after_create callback
      expect(event).to have_received(:send_patient_notification)
    end
  end

  describe ".ransackable_attributes" do
    it "returns the correct attributes" do
      expect(described_class.ransackable_attributes).to include("name", "audience", "status", "location")
    end
  end

  describe ".ransackable_associations" do
    it "returns the correct associations" do
      expect(described_class.ransackable_associations).to include("barangay", "posted_by", "images_attachments", "images_blobs", "rich_text_description")
    end
  end
end
