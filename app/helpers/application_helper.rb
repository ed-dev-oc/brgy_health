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
