require 'rails_helper'

RSpec.describe "SuperAdmin::Dashboards", type: :request do
  describe "GET /index" do
    it "renders the index template" do
      get "/super_admin/dashboard"
      expect(response).to render_template("index")
    end
  end
end
