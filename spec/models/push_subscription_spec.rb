require 'rails_helper'

RSpec.describe PushSubscription, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:endpoint) }
  it { should validate_presence_of(:p256dh) }
  it { should validate_presence_of(:auth) }
end
