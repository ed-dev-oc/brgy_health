module SuperAdmin::CmsHelper
  def main_view_page_helper(section)
    if section == "homepage_hero_banner"
      root_path
    else
      main_page_path(section)
    end
  end
end
