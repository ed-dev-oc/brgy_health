require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Barangay::AppointmentsHelper. For example:
#
# describe Barangay::AppointmentsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Barangay::AppointmentsHelper, type: :helper do
  let(:appointment) { double('Appointment', status: status, flag_list: flag_list) }
  let(:status) { 'pending' }
  let(:flag_list) { [] }

  before do
    stub_const('Appointment::VALID_FOR_RESCHEDULE_STATUS', [ :pending, :approved ])
    # Set @appointment instance variable as used in the helper
    helper.instance_variable_set(:@appointment, appointment)
  end

  it 'returns true if status is valid and flag_list does not include rescheduled' do
    allow(appointment).to receive(:status).and_return('pending')
    allow(appointment).to receive(:flag_list).and_return([])
    expect(helper.display_resceduled_button?(appointment)).to be true
  end

  it 'returns false if status is not valid' do
    allow(appointment).to receive(:status).and_return('cancelled')
    allow(appointment).to receive(:flag_list).and_return([])
    expect(helper.display_resceduled_button?(appointment)).to be false
  end

  it 'returns false if flag_list includes rescheduled' do
    allow(appointment).to receive(:status).and_return('pending')
    allow(appointment).to receive(:flag_list).and_return([ 'rescheduled' ])
    expect(helper.display_resceduled_button?(appointment)).to be false
  end
end
