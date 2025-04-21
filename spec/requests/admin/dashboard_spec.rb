require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do
  describe "GET /index" do
    it "renders the index template" do
      get "/admin/dashboard"
      expect(response).to render_template("index")
    end
  end
end
