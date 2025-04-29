class Barangay::PagesController < BarangayController
  def home
  end

  def show
    if template_exists?(params[:page], [ "pages" ])
      render params[:page]
    else
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end

  def contact_us
  end

  def about_us
  end
end
