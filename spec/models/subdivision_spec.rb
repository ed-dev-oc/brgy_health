require 'rails_helper'

RSpec.describe Subdivision, type: :model do
  fixtures :subdivisions

  describe "presence validations" do
    it "is invalid without an name" do
      subdivision = subdivisions(:purok_one)
      subdivision.name = nil

      expect(subdivision).not_to be_valid
      expect(subdivision.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an barangay" do
      subdivision = subdivisions(:purok_one)
      subdivision.barangay_id = nil

      expect(subdivision).not_to be_valid
      expect(subdivision.errors[:barangay_id]).to include("can't be blank")
    end
  end

  describe "uniqueness validations" do
    it "is invalid with a duplicate name" do
      subdivision = subdivisions(:purok_one)
      subdivision.barangay_id = subdivisions(:zone_one).barangay_id
      subdivision.name = subdivisions(:zone_one).name

      expect(subdivision).not_to be_valid
      expect(subdivision.errors[:name]).to include("has already been taken")
    end
  end

  describe "slug validations" do
    it "has a valid slug equal to name" do
      subdivision = subdivisions(:purok_one)
      subdivision.slug = nil
      subdivision.save

      expect(subdivision.slug).to eq("purok-one")
    end
  end
end
