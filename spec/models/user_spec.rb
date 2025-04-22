require 'rails_helper'

RSpec.describe User, type: :model do
  fixtures :users, :subdivisions, :barangays

  describe "valid users validations" do
    it "has a valid super_admin user" do
      expect(users(:super_admin)).to be_valid
    end

    it "has a valid admin user" do
      expect(users(:admin)).to be_valid
    end

    it "has a valid staff user" do
      expect(users(:staff)).to be_valid
    end

    it "has a valid patient user" do
      expect(users(:patient)).to be_valid
    end
  end

  describe "invalid presence validations" do
    it "is invalid without an email" do
      user = users(:patient)
      user.email = nil

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid without an first_name" do
      user = users(:patient)
      user.first_name = nil

      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it "is invalid without an last_name" do
      user = users(:patient)
      user.last_name = nil

      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end
  end

  describe "invalid uniqueness validations" do
    it "is invalid with a duplicate email" do
      user = users(:super_admin)
      user.email = users(:admin).email

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "is invalid with a duplicate public_uid" do
      user = users(:super_admin)
      user.public_uid = users(:admin).public_uid

      expect(user).not_to be_valid
      expect(user.errors[:public_uid]).to include("has already been taken")
    end

    it "is invalid with a duplicate phone_number" do
      user = users(:super_admin)
      user.phone_number = users(:admin).phone_number

      expect(user).not_to be_valid
      expect(user.errors[:phone_number]).to include("has already been taken")
    end

    it "is invalid with a duplicate full_name" do
      user = users(:super_admin)
      user.first_name = users(:admin).first_name
      user.middle_name = users(:admin).middle_name
      user.last_name = users(:admin).last_name
      user.suffix = users(:admin).suffix

      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("with this full name already exists")
    end
  end

  describe "User barangay and subdivision validations" do
    it "has a valid barangay and subdivision" do
      expect(users(:admin)).to be_valid
      expect(users(:staff)).to be_valid
      expect(users(:patient)).to be_valid
      expect(users(:super_admin)).to be_valid
    end

    it "has a invalid barangay and subdivision" do
      admin = users(:admin)
      admin.barangay = nil
      admin.subdivision = nil

      staff = users(:staff)
      staff.barangay = nil
      staff.subdivision = nil

      patient = users(:patient)
      patient.barangay = nil
      patient.subdivision = nil

      expect(staff).not_to be_valid
      expect(patient).not_to be_valid
      expect(admin).not_to be_valid
    end
  end
end
