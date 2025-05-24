require 'rails_helper'

RSpec.describe "SuperAdmin::Barangays", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/super_admin/barangays/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/super_admin/barangays/show"
      expect(response).to have_http_status(:success)
    end
  end

end
