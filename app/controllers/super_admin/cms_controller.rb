class SuperAdmin::CmsController < SuperAdminController
  before_action :set_pages, only: [ :index ]
  before_action :set_page, only: [ :update ]

  def index
  end

  def update
    if @page.update(page_params)
      redirect_to super_admin_cms_path, notice: "Page was successfully updated."

      StaticPageUpdatedNotifier.with(record: @page).deliver(User.admin.tagged_with([ "require_validation" ], exclude: true))
    else
      redirect_to super_admin_cms_path, status: :unprocessable_entity, alert: "Page was not updated."
    end
  end

  private

  def page_params
    params.require(:page).permit(:title, :subheadline, :image, :latitude, :longitude, :content)
  end

  def set_pages
    @pages = Page.includes(:image_attachment, :rich_text_content).where(barangay_id: nil)
  end

  def set_page
    @page = Page.find(params[:id])

    if @page.nil?
      redirect_to super_admin_cms_path, status: :see_other, alert: "Page not found."
    end
  end
end
