require 'rails_helper'

RSpec.describe "admin/health_programs/edit", type: :view do
  let(:admin_health_program) {
    Admin::HealthProgram.create!(
      barangay_id: "",
      name: "MyString",
      description: "MyText",
      status: 1
    )
  }

  before(:each) do
    assign(:admin_health_program, admin_health_program)
  end

  it "renders the edit admin_health_program form" do
    render

    assert_select "form[action=?][method=?]", admin_health_program_path(admin_health_program), "post" do

      assert_select "input[name=?]", "admin_health_program[barangay_id]"

      assert_select "input[name=?]", "admin_health_program[name]"

      assert_select "textarea[name=?]", "admin_health_program[description]"

      assert_select "input[name=?]", "admin_health_program[status]"
    end
  end
end
