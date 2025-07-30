require 'rails_helper'

RSpec.describe AppointmentReport, type: :model do
  let(:barangay) { create(:barangay) }
  let(:patient) { create(:user, phone_number: '09170000001', first_name: 'Patient', last_name: 'One', email: 'patient1@example.com') }
  let(:health_worker) { create(:user, phone_number: '09170000002', first_name: 'Health', last_name: 'Worker', email: 'healthworker@example.com') }
  let(:announcement_posted_by) { create(:user, phone_number: '09170000003', first_name: 'Announce', last_name: 'Poster', email: 'announceposter@example.com') }
  let(:announcement) { create(:announcement, barangay: barangay, posted_by: announcement_posted_by) }
  let(:appointment_report) do
    described_class.new(
      barangay: barangay,
      patient: patient,
      health_worker: health_worker,
      announcement: announcement,
      status: :pending,
      scheduled_at: 2.days.from_now
    )
  end

  it 'is readonly' do
    expect(appointment_report.readonly?).to be true
  end

  it 'has correct associations' do
    expect(appointment_report).to respond_to(:patient)
    expect(appointment_report).to respond_to(:health_worker)
    expect(appointment_report).to respond_to(:announcement)
  end

  it 'defines status enum' do
    expect(described_class.statuses.keys).to include('pending', 'approved', 'completed', 'rejected', 'cancelled')
  end

  it 'responds to scopes' do
    expect(described_class).to respond_to(:upcoming)
    expect(described_class).to respond_to(:past)
    expect(described_class).to respond_to(:by_status)
    expect(described_class).to respond_to(:by_barangay)
  end
end
