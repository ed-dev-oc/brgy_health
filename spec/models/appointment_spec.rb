require 'rails_helper'

RSpec.describe Appointment, type: :model do
  fixtures :barangays, :announcements, :users, :appointments

  let(:sample_barangay) { barangays(:lao) }
  let(:sample_announcement) { announcements(:first_announcement) }
  let(:health_worker) { users(:admin) }
  let(:patient) { users(:patient) }
  let(:upcoming_appointment) { appointments(:first_appointment) }
  let(:follow_up_appointment) { appointments(:follow_up_appointment) }

  describe 'associations' do
    it { is_expected.to belong_to(:barangay) }
    it { is_expected.to belong_to(:announcement) }
    it { is_expected.to belong_to(:health_worker).optional.class_name('User') }
    it { is_expected.to belong_to(:patient).class_name('User') }
    it { is_expected.to belong_to(:follow_up).optional.class_name('Appointment') }
  end

  describe 'validations' do
    it { should validate_presence_of(:scheduled_at) }
  end

  describe 'creating a valid appointment' do
    it 'is valid with all required attributes' do
      appointment = Appointment.new(
        barangay: sample_barangay,
        announcement: sample_announcement,
        patient: patient,
        scheduled_at: DateTime.now + 1.day
      )
      expect(appointment).to be_valid
    end

    it 'is valid without a health_worker' do
      appointment = Appointment.new(
        barangay: sample_barangay,
        announcement: sample_announcement,
        patient: patient,
        health_worker: nil,
        scheduled_at: DateTime.now + 1.day
      )
      expect(appointment).to be_valid
    end
  end

  describe 'creating an invalid appointment' do
    it 'is invalid without a scheduled_at' do
      appointment = Appointment.new(scheduled_at: nil)
      expect(appointment).not_to be_valid
      expect(appointment.errors[:scheduled_at]).to include("can't be blank")
    end

    it 'is invalid without a barangay' do
      appointment = Appointment.new(barangay: nil)
      expect(appointment).not_to be_valid
    end

    it 'is invalid without a patient' do
      appointment = Appointment.new(patient: nil)
      expect(appointment).not_to be_valid
    end
  end

  describe 'set flag' do
    it 'is pending by default' do
      appointment = Appointment.new(
        barangay: sample_barangay,
        announcement: sample_announcement,
        health_worker: health_worker,
        patient: patient,
        reason: "Vaccination",
        scheduled_at: sample_announcement.start_date
      )
      appointment.save

      expect(appointment.flag_list).to include("pending")
    end

    it 'is completed when notes are saved' do
      upcoming_appointment.notes = "None"
      upcoming_appointment.save

      expect(upcoming_appointment.flag_list).not_to include("pending")
      expect(upcoming_appointment.flag_list).to include("completed")
    end
  end
end
