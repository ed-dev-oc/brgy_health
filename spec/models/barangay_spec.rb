require 'rails_helper'

RSpec.describe Barangay, type: :model do
  fixtures :barangays

  describe "full address" do
    it "has a valid full address" do
      expect(barangays(:bagong_buhay)).to be_valid
    end

    it "has an invalid duplicate full address" do
      barangay = barangays(:bagong_buhay)
      barangay.name = barangays(:lao).name
      barangay.slug = barangays(:lao).slug
      barangay.region = barangays(:lao).region
      barangay.province = barangays(:lao).province
      barangay.city = barangays(:lao).city

      expect(barangay).not_to be_valid
      expect(barangay.errors[:name]).to include("has already been taken")
    end
  end

  describe "invalid presence validations" do
    it "is invalid without a name" do
      barangay = barangays(:bagong_buhay)
      barangay.name = nil

      expect(barangay).not_to be_valid
      expect(barangay.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a region" do
      barangay = barangays(:bagong_buhay)
      barangay.region = nil

      expect(barangay).not_to be_valid
      expect(barangay.errors[:region]).to include("can't be blank")
    end

    it "is invalid without a province" do
      barangay = barangays(:bagong_buhay)
      barangay.province = nil

      expect(barangay).not_to be_valid
      expect(barangay.errors[:province]).to include("can't be blank")
    end

    it "is invalid without a city" do
      barangay = barangays(:bagong_buhay)
      barangay.city = nil

      expect(barangay).not_to be_valid
      expect(barangay.errors[:city]).to include("can't be blank")
    end
  end

  describe "slug / subdomain validations" do
    it "is valid when name equals slug and subdomain" do
      barangay = barangays(:bagong_buhay)
      barangay.slug = nil
      barangay.save

      expect(barangay.slug).to eq("bagong-buhay")
      expect(barangay.subdomain).to eq("bagong-buhay")
    end

    it "generates slug and subdomain if both are nil" do
      barangay = barangays(:bagong_buhay)
      barangay.slug = nil
      barangay.subdomain = nil
      barangay.save

      expect(barangay.slug).to eq("bagong-buhay")
      expect(barangay.subdomain).to eq("bagong-buhay")
    end
  end
end
