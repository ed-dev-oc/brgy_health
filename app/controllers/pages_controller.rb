class PagesController < ApplicationController
  def home
    @hero_banner = Page.find_by(barangay_id: nil, section: "homepage_hero_banner")
    @barangays = Barangay.verified.includes(pages: :image_attachment).order(created_at: :desc)
    @testimonials = ActsAsTenant.without_tenant do
      Testimonial.visible.includes(:barangay, user: [ :profile_attachment ]).order(created_at: :desc)
    end
    @verified_barangays_count = @barangays.size
    @registered_residents_count = ActsAsTenant.without_tenant { User.where(role: :patient).count }
  end

  def show
    if template_exists?(params[:page], [ "pages" ]) && current_tenant.nil?
      @page = Page.find_by(barangay_id: nil, section: params[:page].to_sym) || Page.find_by(section: params[:page].to_sym)

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
