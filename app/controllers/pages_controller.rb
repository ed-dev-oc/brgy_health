class PagesController < ApplicationController
  def home
    @hero_banner = Page.find_by(barangay_id: nil, section: "homepage_hero_banner")
  end

  def show
    if template_exists?(params[:page], [ "pages" ]) && current_tenant.nil?
      @page = Page.find_by(section: params[:page].to_sym)

      if @page.nil?
        render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
        return
      else
        @page.notifications.where(recipient: current_user).mark_as_read if user_signed_in?
      end

      render params[:page]
    else
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end
end
