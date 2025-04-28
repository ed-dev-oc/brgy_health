require 'rails_helper'

RSpec.describe "admin/health_programs/index", type: :view do
  before(:each) do
    assign(:admin_health_programs, [
      Admin::HealthProgram.create!(
        barangay_id: "",
        name: "Name",
        description: "MyText",
        status: 2
      ),
      Admin::HealthProgram.create!(
        barangay_id: "",
        name: "Name",
        description: "MyText",
        status: 2
      )
    ])
  end

  it "renders a list of admin/health_programs" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
  end
end
