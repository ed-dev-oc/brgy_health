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
    it { is_expected.to belong_to(:announcement).required }
    it { is_expected.to belong_to(:health_worker).optional.with_foreign_key('health_worker_id').class_name('User') }
    it { is_expected.to belong_to(:patient).with_foreign_key('patient_id').class_name('User') }
    it { is_expected.to belong_to(:follow_up).optional.with_foreign_key('follow_up_id').class_name('Appointment') }
    it { is_expected.to have_many(:noticed_events).dependent(:destroy).class_name('Noticed::Event') }
    it { is_expected.to have_many(:notifications).through(:noticed_events).class_name('Noticed::Notification') }
    it { is_expected.to have_one(:parent_appointment).dependent(:nullify).inverse_of(:follow_up).class_name('Appointment') }
  end

  describe 'validations' do
    it { should validate_presence_of(:scheduled_at) }

    context 'when status is cancelled' do
      it 'validates presence of cancel_reason' do
        appointment = Appointment.new(
          barangay: sample_barangay,
          announcement: sample_announcement,
          patient: patient,
          scheduled_at: sample_announcement.start_date,
          status: :cancelled,
          cancel_reason: nil
        )
        expect(appointment).not_to be_valid
        expect(appointment.errors[:cancel_reason]).to include("can't be blank")
      end
    end

    context 'when flag_list includes reschedule' do
      it 'validates presence of reschedule_reason' do
        appointment = Appointment.new(
          barangay: sample_barangay,
          announcement: sample_announcement,
          patient: patient,
          scheduled_at: sample_announcement.start_date,
          reschedule_reason: nil
        )
        allow(appointment).to receive(:flag_list).and_return([ "reschedule" ])
        appointment.valid?
        expect(appointment.errors[:reschedule_reason]).to include("can't be blank")
      end
    end

    context 'scheduled_at_within_announcement_range' do
      it 'is invalid if scheduled_at is outside announcement range' do
        appointment = Appointment.new(
          barangay: sample_barangay,
          announcement: sample_announcement,
          patient: patient,
          scheduled_at: sample_announcement.start_date - 1.day
        )
        expect(appointment).not_to be_valid
        expect(appointment.errors[:scheduled_at]).to include(/must be during the announcement's time range/)
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values([ :pending, :approved, :completed, :rejected, :cancelled ]) }
  end

  describe 'creating a valid appointment' do
    it 'is valid with all required attributes' do
      appointment = Appointment.new(
        barangay: sample_barangay,
        announcement: sample_announcement,
        patient: patient,
        scheduled_at: sample_announcement.start_date.advance(hours: 1)
      )
      expect(appointment).to be_valid
    end

    it 'is valid without a health_worker' do
      appointment = Appointment.new(
        barangay: sample_barangay,
        announcement: sample_announcement,
        patient: patient,
        health_worker: nil,
        scheduled_at: sample_announcement.start_date.advance(hours: 1)
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
      ActsAsTenant.with_mutable_tenant do
        appointment = Appointment.new(barangay: nil, announcement: sample_announcement, patient: patient, scheduled_at: sample_announcement.start_date)
        expect(appointment).not_to be_valid
      end
    end

    it 'is invalid without a patient' do
      appointment = Appointment.new(barangay: sample_barangay, announcement: sample_announcement, patient: nil, scheduled_at: sample_announcement.start_date)
      expect(appointment).not_to be_valid
    end
  end

  describe 'callbacks' do
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
      expect(appointment.status).to eq("pending")
    end

    it 'is completed when notes are saved and status is approved' do
      upcoming_appointment.update(status: :approved)
      upcoming_appointment.notes = "None"
      upcoming_appointment.save
      expect(upcoming_appointment.status).to eq("completed")
    end
  end
end
