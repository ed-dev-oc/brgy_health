module Admin::CmsHelper
  def barangay_view_page_helper(section)
    if section == "homepage_hero_banner"
      root_path
    elsif section == "about_us"
      about_us_pages_path
    elsif section == "contact_us"
      contact_us_pages_path
    end
  end
end
