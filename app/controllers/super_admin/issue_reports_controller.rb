class SuperAdmin::IssueReportsController < SuperAdminController
  before_action :set_issue_report, only: [ :status_update ]

  def index
    @q = IssueReport.ransack(params[:q])
    @pagy, @issue_reports = pagy(@q.result(distinct: true))
  end

  def status_update
    if @issue_report.update(status_update_params)
      flash[:notice] = "Issue report status was successfully updated."
    else
      flash.now[:alert] = "Issue report status was not updated."
    end
  end

  private

  def set_issue_report
    @issue_report = IssueReport.find_by(public_uid: params[:id])
  end

  def status_update_params
    params.require(:issue_report).permit(:status)
  end
end
