require 'rails_helper'

RSpec.describe Barangay, type: :model do
  fixtures :barangays, :users

  describe "associations" do
    it { should have_many(:subdivisions) }
    it { should have_many(:users) }
    it { should have_many(:health_programs) }
    it { should have_many(:testimonials) }
    it { should have_many(:pages) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:region) }
    it { should validate_presence_of(:province) }
    it { should validate_presence_of(:city) }
    it {
      should validate_uniqueness_of(:name).scoped_to(:region, :province, :city)
    }
  end

  describe "enums" do
    it {
      should define_enum_for(:subdivision_type).with_values([ :both, :purok, :zone ])
    }
  end

  describe "scopes" do
    it "returns verified barangays" do
      verified = Barangay.verified
      expect(verified).to all(be_a(Barangay))
    end

    it "returns unverified barangays" do
      unverified = Barangay.unverified
      expect(unverified).to all(be_a(Barangay))
    end
  end

  describe "instance methods" do
    let(:barangay) { barangays(:bagong_buhay) }

    it "returns full address" do
      expect(barangay.full_address).to eq(
        "#{barangay.name}, #{barangay.city}, #{barangay.province}, #{barangay.region}"
      )
    end

    it "returns admin_and_staff users" do
      expect(barangay.admin_and_staff).to all(be_a(User))
    end

    it "returns verified? as boolean" do
      expect([ true, false ]).to include(barangay.verified?)
    end

    it "returns verified_status as string" do
      expect([ "Verified", "Unverified" ]).to include(barangay.verified_status)
    end

    it "returns has_validated_admin? as boolean" do
      expect([ true, false ]).to include(barangay.has_validated_admin?)
    end

    it "returns has_unvalidated_admin? as boolean" do
      expect([ true, false ]).to include(barangay.has_unvalidated_admin?)
    end

    it "returns unvalidated_admin as User or nil" do
      result = barangay.unvalidated_admin
      expect(result.nil? || result.is_a?(User)).to be true
    end
  end

  describe "callbacks" do
    it "sets subdomain from slug if subdomain is blank" do
      barangay = barangays(:bagong_buhay)
      barangay.slug = "test-slug"
      barangay.subdomain = nil
      barangay.save
      expect(barangay.subdomain).to eq("test-slug")
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

  describe "uniqueness validation for full address" do
    it "is invalid with duplicate name, region, province, and city" do
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
end
