require 'rails_helper'

RSpec.describe Announcement, type: :model do
  fixtures :announcements

  describe "presence validations" do
    it "is invalid without a name" do
      announcement = announcements(:first_announcement)
      announcement.name = nil

      expect(announcement).not_to be_valid
      expect(announcement.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a start_date" do
      announcement = announcements(:first_announcement)
      announcement.start_date = nil

      expect(announcement).not_to be_valid
      expect(announcement.errors[:start_date]).to include("can't be blank")
    end

    it "is invalid without a end_date" do
      announcement = announcements(:first_announcement)
      announcement.end_date = nil

      expect(announcement).not_to be_valid
      expect(announcement.errors[:end_date]).to include("can't be blank")
    end

    it "is invalid without a open_time" do
      announcement = announcements(:first_announcement)
      announcement.open_time = nil

      expect(announcement).not_to be_valid
      expect(announcement.errors[:open_time]).to include("can't be blank")
    end

    it "is invalid without a close_time" do
      announcement = announcements(:first_announcement)
      announcement.close_time = nil

      expect(announcement).not_to be_valid
      expect(announcement.errors[:close_time]).to include("can't be blank")
    end

    it "is invalid without a location" do
      announcement = announcements(:first_announcement)
      announcement.location = nil

      expect(announcement).not_to be_valid
      expect(announcement.errors[:location]).to include("can't be blank")
    end

    it "is invalid without a max_patients" do
      announcement = announcements(:first_announcement)
      announcement.max_patients = nil

      expect(announcement).not_to be_valid
      expect(announcement.errors[:max_patients]).to include("can't be blank")
    end

    it "is invalid without a audience" do
      announcement = announcements(:first_announcement)
      announcement.audience = nil

      expect(announcement).not_to be_valid
      expect(announcement.errors[:audience]).to include("can't be blank")
    end
  end

  describe "numericality validations" do
    it "accepts positive numbers" do
      announcement = announcements(:first_announcement)

      expect(announcement).to be_valid
    end

    it "rejects negative numbers" do
      announcement = announcements(:first_announcement)
      announcement.max_patients = -1

      expect(announcement).not_to be_valid
      expect(announcement.errors[:max_patients]).to include("must be a positive whole number")
    end

    it "rejects non-numeric values" do
      announcement = announcements(:first_announcement)
      announcement.max_patients = "ten"

      expect(announcement).not_to be_valid
    end
  end

  describe "date / time validations" do
    it "is invalid with a past start date" do
      announcement = announcements(:first_announcement)
      announcement.start_date = Time.current.advance(days: -1)

      expect(announcement).not_to be_valid
      expect(announcement.errors[:start_date]).to include("must be in the future")
    end

    it "is invalid when end_date is before start_date" do
      announcement = announcements(:first_announcement)
      announcement.end_date = announcement.start_date.advance(days: -1)

      expect(announcement).not_to be_valid
      expect(announcement.errors[:end_date]).to include("must be after the start date")
    end

    it "is valid when dates are in correct sequence" do
      announcement = announcements(:first_announcement)

      expect(announcement).to be_valid
    end

    it "validates open_time is before close_time" do
      announcement = announcements(:first_announcement)

      expect(announcement).to be_valid
    end

    it "rejects open_time after close_time" do
      announcement = announcements(:first_announcement)
      announcement.open_time = announcement.close_time.advance(minutes: 1)

      expect(announcement).not_to be_valid
      expect(announcement.errors[:open_time]).to include("must be before the close time")
    end

    it "validates close_time is after open_time" do
      announcement = announcements(:first_announcement)

      expect(announcement).to be_valid
    end

    it "rejects close_time before open_time" do
      announcement = announcements(:first_announcement)
      announcement.close_time = announcement.open_time.advance(minutes: -1)

      expect(announcement).not_to be_valid
      expect(announcement.errors[:close_time]).to include("must be after the open time")
    end
  end
end
