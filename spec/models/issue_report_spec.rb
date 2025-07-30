require 'rails_helper'

RSpec.describe IssueReport, type: :model do
  it { should define_enum_for(:issue_type).with_values([ :bug, :feature_request, :ui_ux, :security ]) }
  it { should define_enum_for(:priority).with_values([ :low, :medium, :high, :critical ]) }
  it { should define_enum_for(:module_area).with_values([ :authentication, :dashboard, :reports, :profile, :database, :appointment, :event, :announcement, :other ]) }
  it { should define_enum_for(:status).with_values([ :open, :in_progress, :resolved, :closed ]) }
  it { should validate_presence_of(:issue_type) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:priority) }
  it { should validate_presence_of(:module_area) }
  it { should validate_presence_of(:email) }
  it { should have_many_attached(:images) }
end
