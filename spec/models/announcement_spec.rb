require 'rails_helper'


RSpec.describe Announcement, type: :model do
  fixtures :announcements, :action_text_rich_texts

  let(:announcement) { announcements(:first_announcement) }

  describe "presence validations" do
    it "is invalid without a name" do
      announcement.name = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a description" do
      announcement.description = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:description]).to include("can't be blank")
    end

    it "is invalid without a start_date" do
      announcement.start_date = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:start_date]).to include("can't be blank")
    end

    it "is invalid without a end_date" do
      announcement.end_date = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:end_date]).to include("can't be blank")
    end

    it "is invalid without a open_time" do
      announcement.open_time = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:open_time]).to include("can't be blank")
    end

    it "is invalid without a close_time" do
      announcement.close_time = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:close_time]).to include("can't be blank")
    end

    it "is invalid without a location" do
      announcement.location = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:location]).to include("can't be blank")
    end

    it "is invalid without a max_patients" do
      announcement.max_patients = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:max_patients]).to include("can't be blank")
    end

    it "is invalid without a audience" do
      announcement.audience = nil
      expect(announcement).not_to be_valid
      expect(announcement.errors[:audience]).to include("can't be blank")
    end
  end

  describe "numericality validations" do
    it "accepts positive numbers" do
      expect(announcement).to be_valid
    end

    it "rejects negative numbers" do
      announcement.max_patients = -1
      expect(announcement).not_to be_valid
      expect(announcement.errors[:max_patients]).to include("must be a positive whole number")
    end

    it "rejects non-numeric values" do
      announcement.max_patients = "ten"
      expect(announcement).not_to be_valid
    end

    it "rejects zero as max_patients" do
      announcement.max_patients = 0
      expect(announcement).not_to be_valid
      expect(announcement.errors[:max_patients]).to include("must be a positive whole number")
    end

    it "accepts a large max_patients value" do
      announcement.max_patients = 100_000
      expect(announcement).to be_valid
    end
  end

  describe "date / time validations" do
    it "is invalid with a past start date" do
      ann = announcement.dup
      ann.start_date = Time.current.advance(days: -1)
      expect(ann).not_to be_valid
      expect(ann.errors[:start_date]).to include("must be in the future")
    end

    it "is invalid when end_date is before start_date" do
      announcement.end_date = announcement.start_date.advance(days: -1)
      expect(announcement).not_to be_valid
      expect(announcement.errors[:end_date]).to include("must be after the start date")
    end

    it "is valid when dates are in correct sequence" do
      expect(announcement).to be_valid
    end

    it "is invalid when end_date equals start_date" do
      announcement.end_date = announcement.start_date
      expect(announcement).not_to be_valid
      expect(announcement.errors[:end_date]).to include("must be after the start date")
    end

    it "validates open_time is before close_time" do
      expect(announcement).to be_valid
    end

    it "rejects open_time after close_time" do
      announcement.open_time = announcement.close_time.advance(minutes: 1)
      expect(announcement).not_to be_valid
      expect(announcement.errors[:open_time]).to include("must be before the close time")
    end

    it "validates close_time is after open_time" do
      expect(announcement).to be_valid
    end

    it "rejects close_time before open_time" do
      announcement.close_time = announcement.open_time.advance(minutes: -1)
      expect(announcement).not_to be_valid
      expect(announcement.errors[:close_time]).to include("must be after the open time")
    end

    it "is invalid when open_time equals close_time" do
      announcement.open_time = announcement.close_time
      expect(announcement).not_to be_valid
      expect(announcement.errors[:open_time]).to include("must be before the close time")
    end
  end

  describe "status enum" do
    it "accepts valid statuses" do
      Announcement.statuses.keys.each do |status|
        announcement.status = status
        expect(announcement).to be_valid
      end
    end

    it "rejects invalid status" do
      expect { announcement.status = "not_a_status" }.to raise_error(ArgumentError)
    end
  end

  describe "audience edge cases" do
    it "is invalid with empty string" do
      announcement.audience = ""
      expect(announcement).not_to be_valid
    end

    it "accepts a long string" do
      announcement.audience = "a" * 255
      expect(announcement).to be_valid
    end
  end

  describe "images presence validation" do
    it "is invalid without images on create" do
      ann = announcement.dup
      allow(ann).to receive(:images).and_return([])
      ann.instance_variable_set(:@new_record, true)
      ann.validate
      expect(ann.errors[:images]).to include("must have at least one image")
    end
  end

  describe "health_program association" do
    it "is valid without a health_program" do
      announcement.health_program = nil
      expect(announcement).to be_valid
    end
  end

  describe "description and location edge cases" do
    it "is invalid with empty description" do
      announcement.description = ""
      expect(announcement).not_to be_valid
    end

    it "accepts a long description" do
      announcement.description = "a" * 1000
      expect(announcement).to be_valid
    end

    it "is invalid with empty location" do
      announcement.location = ""
      expect(announcement).not_to be_valid
    end

    it "accepts a long location" do
      announcement.location = "a" * 255
      expect(announcement).to be_valid
    end
  end
end
