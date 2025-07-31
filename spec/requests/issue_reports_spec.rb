
require 'rails_helper'
require 'debug'


RSpec.describe "IssueReports", type: :request do
  describe "POST /issue_reports" do
    let(:valid_attributes) do
      {
        issue_report: {
          issue_type: "bug",
          title: "Sample Issue",
          description: "There is a problem.",
          priority: "medium",
          module_area: "authentication",
          url: "http://example.com",
          email: "user@example.com"
        }
      }
    end

    let(:invalid_attributes) do
      {
        issue_report: {
          issue_type: nil,
          title: nil,
          description: nil,
          priority: nil,
          module_area: nil,
          url: nil,
          email: nil
        }
      }
    end

    it "creates a new IssueReport with valid params" do
      expect {
        post issue_reports_path, params: valid_attributes, headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
      }.to change(IssueReport, :count).by(1)
      expect(response).to have_http_status(:success).or have_http_status(:redirect)
    end

    it "does not create a new IssueReport with invalid params" do
      expect {
        post issue_reports_path, params: invalid_attributes, headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
      }.not_to change(IssueReport, :count)
      expect(response).to have_http_status(:success).or have_http_status(:unprocessable_entity).or have_http_status(:ok)
    end
  end
end
