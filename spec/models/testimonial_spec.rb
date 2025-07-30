require 'rails_helper'

RSpec.describe Testimonial, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:data) }
  it { should validate_presence_of(:rating) }
  it { should define_enum_for(:status).with_values([ :hidden, :visible ]) }
end
