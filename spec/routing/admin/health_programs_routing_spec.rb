require "rails_helper"

RSpec.describe Admin::HealthProgramsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/health_programs").to route_to("admin/health_programs#index")
    end

    it "routes to #new" do
      expect(get: "/admin/health_programs/new").to route_to("admin/health_programs#new")
    end

    it "routes to #show" do
      expect(get: "/admin/health_programs/1").to route_to("admin/health_programs#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/health_programs/1/edit").to route_to("admin/health_programs#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/health_programs").to route_to("admin/health_programs#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/health_programs/1").to route_to("admin/health_programs#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/health_programs/1").to route_to("admin/health_programs#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/health_programs/1").to route_to("admin/health_programs#destroy", id: "1")
    end
  end
end
