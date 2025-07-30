require 'rails_helper'

RSpec.describe HealthProgram, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
  it { should define_enum_for(:status).with_values([ :active, :inactive ]) }
  it { should have_many(:announcements) }
  it "validates uniqueness of name scoped to barangay_id" do
    barangay1 = create(:barangay)
    barangay2 = create(:barangay)

    ActsAsTenant.with_tenant(barangay1) do
      create(:health_program, name: "Prenatal Test", barangay: barangay1)
      hp2 = build(:health_program, name: "Prenatal Test", barangay: barangay1)
      expect(hp2).not_to be_valid
      expect(hp2.errors[:name]).to include("has already been taken")
    end

    ActsAsTenant.with_tenant(barangay2) do
      hp3 = build(:health_program, name: "Prenatal Test", barangay: barangay2)
      expect(hp3).to be_valid
    end
  end
end
