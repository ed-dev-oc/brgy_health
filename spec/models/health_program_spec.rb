require 'rails_helper'

RSpec.describe HealthProgram, type: :model do
  # fixtures :health_programs, :barangays

  # describe "emptiness validation" do
  #   it "has a invalid name" do
  #     health_program = health_programs(:bagong_buhay_prenatal)
  #     health_program.name = nil

  #     expect(health_program).not_to be_valid
  #   end

  #   it "has a valid name" do
  #     health_program = health_programs(:bagong_buhay_prenatal)

  #     expect(health_program).to be_valid
  #   end

  #   it "has a invalid description" do
  #     health_program = health_programs(:bagong_buhay_prenatal)
  #     health_program.description = nil

  #     expect(health_program).not_to be_valid
  #   end

  #   it "has a valid description" do
  #     health_program = health_programs(:bagong_buhay_prenatal)

  #     expect(health_program).to be_valid
  #   end
  # end

  # describe "uniqueness validation" do
  #   it "has a invalid duplicate name" do
  #     health_program = health_programs(:bagong_buhay_prenatal)
  #     health_program.name = health_programs(:bagong_buhay_newborn_screening).name

  #     expect(health_program).not_to be_valid
  #   end

  #   it "has a valid duplicate name" do
  #     ActsAsTenant.with_mutable_tenant do
  #       health_program = health_programs(:bagong_buhay_prenatal)
  #       health_program.name = health_programs(:bagong_buhay_newborn_screening).name
  #       health_program.barangay = barangays(:lao)

  #       expect(health_program).to be_valid
  #     end
  #   end
  # end
end
