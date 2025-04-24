require 'rails_helper'

RSpec.describe "SuperAdmin::Dashboards", type: :request do
  describe "GET /index" do
    it "renders the index template" do
      ActsAsTenant.without_tenant do
        # Tenant checking is disabled for all code in this block
        get "/super_admin/dashboard"
        expect(response).to render_template("index")
      end
    end
  end
end
