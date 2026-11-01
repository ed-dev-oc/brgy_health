class Barangay::PagesController < BarangayController
  def home
    @hero_banner = Page.find_by(section: "homepage_hero_banner")

    if user_signed_in?
      @hero_banner&.notifications&.where(recipient: current_user)&.mark_as_read

      if current_user.admin?
        current_user.notifications.where(type: "StaticPageUpdatedNotifier::Notification").mark_as_read
      end
    end
  end

  def show
    if template_exists?(params[:page], [ "pages" ])
      @page = Page.find_by(section: params[:page].to_sym)

      if @page.nil?
        render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
        return
      end

      @page.notifications.where(recipient: current_user).mark_as_read if user_signed_in?
      render params[:page]
    else
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end

  def contact_us
    @page = Page.find_by(section: :contact_us)
    @admin = User.admin.first

    if @page.nil?
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    else
      @page.notifications.where(recipient: current_user).mark_as_read if user_signed_in?
    end
  end

  def about_us
    @page = Page.find_by(section: :about_us)

    if @page.nil?
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    else
      @page.notifications.where(recipient: current_user).mark_as_read if user_signed_in?
    end
  end
end
