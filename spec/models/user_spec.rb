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

    it "has a invalid barangay" do
      ActsAsTenant.with_mutable_tenant do
        admin = users(:admin)
        admin.barangay = nil

        staff = users(:staff)
        staff.barangay = nil

        patient = users(:patient)
        patient.barangay = nil

        expect(staff).not_to be_valid
        expect(patient).not_to be_valid
        expect(admin).not_to be_valid
      end
    end
  end

  describe "flags validations" do
    it "has a flag if no phone_number is set for super admin" do
      admin = User.create!(
        email: "super_admin_test@test.com",
        first_name: "Super",
        last_name: "Admin",
        role: 0,
        password: "password123",
        password_confirmation: "password123")

      expect(admin.flag_list).to include("no_phone_number")
      expect(admin.flag_list).not_to include("no_subdivision")
      expect(admin.flag_list).not_to include("require_validation")
    end

    it "has a flag if no subdivision, not validated, and no phone_number is set for admin" do
      admin = User.create!(
        email: "admin_test@test.com",
        first_name: "Barangay",
        last_name: "Admin",
        role: 1,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      expect(admin.flag_list).to include("no_phone_number")
      expect(admin.flag_list).to include("no_subdivision")
      expect(admin.flag_list).to include("require_validation")
    end

    it "has a flag if no subdivision and no phone_number is set for staff" do
      admin = User.create!(
        email: "admin_test@test.com",
        first_name: "Barangay",
        last_name: "Admin",
        role: 2,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      expect(admin.flag_list).to include("no_subdivision")
      expect(admin.flag_list).to include("no_phone_number")
      expect(admin.flag_list).not_to include("require_validation")
    end

    it "has a flag if no subdivision and no phone_number is set for patient" do
      admin = User.create!(
        email: "admin_test@test.com",
        first_name: "Barangay",
        last_name: "Admin",
        role: 3,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      expect(admin.flag_list).to include("no_subdivision")
      expect(admin.flag_list).to include("no_phone_number")
      expect(admin.flag_list).not_to include("require_validation")
    end

    it "has no flag no subdivision when user added a subdivision" do
      user = User.create!(
        email: "user_test@test.com",
        first_name: "Barangay",
        last_name: "User",
        role: 1,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      user.update(subdivision_id: 1)

      expect(user.flag_list).not_to include("no_subdivision")
    end

    it "has no flag no phone_number when user added a phone_number" do
      user = User.create!(
        email: "user_test@test.com",
        first_name: "Barangay",
        last_name: "User",
        role: 1,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      user.phone_number = "09099992154"
      user.save

      expect(user.flag_list).not_to include("no_phone_number")
    end
  end

  describe "flags validations" do
    it "has a flag if no phone_number is set for super admin" do
      admin = User.create!(
        email: "super_admin_test@test.com",
        first_name: "Super",
        last_name: "Admin",
        role: 0,
        password: "password123",
        password_confirmation: "password123")

      expect(admin.flag_list).to include("no_phone_number")
      expect(admin.flag_list).not_to include("no_subdivision")
      expect(admin.flag_list).not_to include("require_validation")
    end

    it "has a flag if no subdivision, not validated, and no phone_number is set for admin" do
      admin = User.create!(
        email: "admin_test@test.com",
        first_name: "Barangay",
        last_name: "Admin",
        role: 1,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      expect(admin.flag_list).to include("no_phone_number")
      expect(admin.flag_list).to include("no_subdivision")
      expect(admin.flag_list).to include("require_validation")
    end

    it "has a flag if no subdivision and no phone_number is set for staff" do
      admin = User.create!(
        email: "admin_test@test.com",
        first_name: "Barangay",
        last_name: "Admin",
        role: 2,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      expect(admin.flag_list).to include("no_subdivision")
      expect(admin.flag_list).to include("no_phone_number")
      expect(admin.flag_list).not_to include("require_validation")
    end

    it "has a flag if no subdivision and no phone_number is set for patient" do
      admin = User.create!(
        email: "admin_test@test.com",
        first_name: "Barangay",
        last_name: "Admin",
        role: 3,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      expect(admin.flag_list).to include("no_subdivision")
      expect(admin.flag_list).to include("no_phone_number")
      expect(admin.flag_list).not_to include("require_validation")
    end

    it "has no flag no subdivision when user added a subdivision" do
      user = User.create!(
        email: "user_test@test.com",
        first_name: "Barangay",
        last_name: "User",
        role: 1,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      user.update(subdivision_id: 1)

      expect(user.flag_list).not_to include("no_subdivision")
    end

    it "has no flag no phone_number when user added a phone_number" do
      user = User.create!(
        email: "user_test@test.com",
        first_name: "Barangay",
        last_name: "User",
        role: 1,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123")

      user.phone_number = "09099992154"
      user.save

      expect(user.flag_list).not_to include("no_phone_number")
    end
  end

  describe "platform_staff role" do
    it "is valid without a barangay" do
      staff = User.new(
        email: "platform_staff@test.com",
        first_name: "Platform",
        last_name: "Staff",
        role: :platform_staff,
        password: "password123",
        password_confirmation: "password123"
      )

      expect(staff).to be_valid
      expect(staff.platform_user?).to be true
    end
  end

  describe "default active status" do
    it "defaults patient to active" do
      patient = User.create!(
        email: "new_patient@test.com",
        first_name: "New",
        last_name: "Patient",
        role: :patient,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123"
      )

      expect(patient.flag_list).to include("active")
      expect(patient.active?).to be true
    end

    it "defaults staff to active" do
      staff = User.create!(
        email: "new_staff@test.com",
        first_name: "New",
        last_name: "Staff",
        role: :staff,
        barangay_id: 1,
        password: "password123",
        password_confirmation: "password123"
      )

      expect(staff.flag_list).to include("active")
      expect(staff.active?).to be true
    end
  end

  describe "active_for_authentication?" do
    it "returns true if active" do
      patient = users(:patient)
      patient.flag_list.add("active")
      expect(patient.active_for_authentication?).to be true
    end

    it "returns false if inactive" do
      patient = users(:patient)
      patient.flag_list.add("inactive")
      expect(patient.active_for_authentication?).to be false
      expect(patient.inactive_message).to eq(:inactive)
    end
  end

  describe "admin deactivation restrictions" do
    it "prevents deactivating the only active admin in a barangay" do
      admin = users(:admin)
      admin.flag_list.add("active")
      admin.save!

      # Make sure no other admin is active in barangay 1
      User.where(barangay_id: admin.barangay_id, role: :admin).where.not(id: admin.id).destroy_all

      admin.flag_list.remove("active")
      admin.flag_list.add("inactive")

      expect(admin.save).to be false
      expect(admin.errors[:base]).to include("Each barangay must have at least one active admin.")
    end

    it "allows deactivating an admin if another active admin exists in the same barangay" do
      admin1 = users(:admin)
      admin1.flag_list.add("active")
      admin1.save!

      admin2 = User.create!(
        email: "co_admin@test.com",
        first_name: "Co",
        last_name: "Admin",
        role: :admin,
        barangay_id: admin1.barangay_id,
        password: "password123",
        password_confirmation: "password123"
      )
      admin2.flag_list.remove("require_validation")
      admin2.flag_list.add("active")
      admin2.save!

      admin1.flag_list.remove("active")
      admin1.flag_list.add("inactive")

      expect(admin1.save).to be true
    end
  end
end
