class Admin::CmsController < AdminController
  before_action :set_pages, only: %i[index]
  before_action :set_page, only: %i[update]

  def index
  end

  def update
    if @page.update(page_params)
      redirect_to admin_cms_path, notice: "Page was successfully updated."

      StaticPageUpdatedNotifier.with(record: @page).deliver(User.patient)
    else
      redirect_to admin_cms_path, status: :unprocessable_entity, alert: "Page was not updated."
    end
  end

  private

  def page_params
    params.require(:page).permit(:title, :subheadline, :image, :latitude, :longitude, :content)
  end

  def set_pages
    @pages = Page.all
  end

  def set_page
    @page = Page.find(params[:id])

    if @page.nil?
      redirect_to admin_cms_path, status: :see_other, alert: "Page not found."
    end
  end
end
