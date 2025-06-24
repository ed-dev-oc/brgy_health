class IssueReportsController < ApplicationController
  def create
    @issue_report = IssueReport.new(issue_report_params)

    if @issue_report.save
      flash[:notice] = "Issue report was successfully created."
    else
      flash.now[:alert] = "Issue report was not created."
    end
  end

  private

  def issue_report_params
    params.require(:issue_report).permit(
      :issue_type,
      :title,
      :description,
      :priority,
      :module_area,
      :url,
      :email,
      images: []
    )
  end
end
