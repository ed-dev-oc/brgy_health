require 'rails_helper'

RSpec.describe "SuperAdmin::Testimonials", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/super_admin/testimonials/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/super_admin/testimonials/show"
      expect(response).to have_http_status(:success)
    end
  end

end
