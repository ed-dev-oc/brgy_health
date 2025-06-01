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
  end

  def display_profile_image(user, alt: "Avatar")
    if user.profile.attached?
      image_tag url_for(user.profile.variant(resize_to_limit: [ 200, 200 ]).processed), alt: alt, class: "rounded"
    else
      image_tag "https://placehold.co/80x80/146c43/white?text=#{user.initials}", alt: alt, class: "rounded", style: "width: 200px; height: 200px;"
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

  def badge_status_class(status)
    case status.to_s
    when "active", "visible"
      "text-bg-primary"
    when "approved", "completed"
      "text-bg-success"
    when "pending"
      "text-bg-warning"
    when "rejected", "canceled", "cancelled", "archived"
      "text-bg-danger"
    when "draft", "inactive", "hidden"
      "text-bg-secondary"
    else
      "text-bg-secondary"
    end
  end
end
