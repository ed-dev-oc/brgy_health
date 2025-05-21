module ApplicationHelper
  include Pagy::Frontend

  def navbar_link_status(path)
    current_page?(path) ? "active" : ""
  end

  def administrator_path_helper
    if current_user.super_admin?
      super_admin_dashboard_index_path
    else
      admin_dashboard_index_path
    end
  end

  def navbar_title
    if ActsAsTenant.current_tenant.present?
      ActsAsTenant.current_tenant.name + " Health Center"
    else
      "Barangay Health Center"
    end
  def display_profile_image(user, alt: "Avatar")
    if user.profile.attached?
      image_tag url_for(user.profile.variant(resize_to_limit: [ 200, 200 ]).processed), alt: alt, class: "rounded"
    else
      image_tag "default_avatar.jpg", alt: alt, class: "rounded", style: "width: 200px; height: 200px;"
    end
  end

  def back_button_for_user
    path =
      if current_user.super_admin?
        super_admin_dashboard_index_path
      elsif current_user.admin?
        admin_dashboard_index_path
      else
        root_path
      end

    link_to "Back", path, class: "btn btn-secondary mb-4 col-md-1 ms-1"
  end

  def edit_profile_button(user, label: "Edit profile")
    link_to label, edit_profile_path(user), class: "btn btn-primary col-md-1 ms-1"
  end
end
