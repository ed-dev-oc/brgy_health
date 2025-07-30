require 'rails_helper'

RSpec.describe Page, type: :model do
  it { should define_enum_for(:section).with_values([ :homepage_hero_banner, :about_us, :contact_us, :privacy_policy, :terms_of_use ]) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:subheadline) }
  it { should validate_presence_of(:section) }
  it { should have_one_attached(:image) }
  it { should have_rich_text(:content) }
  it { should have_many(:noticed_events).dependent(:destroy) }
  it { should have_many(:notifications).through(:noticed_events) }
end
