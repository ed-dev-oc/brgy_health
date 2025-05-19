class PagesController < ApplicationController
  before_action :set_pages

  def home
    @hero_banner = Page.find_by(slug: "main-page-hero-banner")
  end

  def show
    if template_exists?(params[:page], [ "pages" ]) && current_tenant.nil?
      @page = Page.find_by(slug: params[:page].gsub("_", "-"))

      if @page.nil?
        render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
        return
      end

      render params[:page]
    else
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end

  private

  def set_pages
    @pages = Page.where(barangay_id: nil)
  end
end
