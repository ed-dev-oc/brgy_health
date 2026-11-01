module ApplicationHelper
  include Pagy::Frontend

  def navbar_link_status(path)
    current_page?(path) ? "active" : ""
  end

  def icon_for_state(path, active_state, inactive_state)
    current_page?(path) ? active_state : inactive_state
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

  def profile_url(user)
    if user.profile.attached?
      url_for(user.profile.variant(resize_to_limit: [ 80, 80 ]).processed)
    else
      "https://placehold.co/80x80/146c43/white?text=#{user.initials}"
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
    when "active", "visible", "follow_up_check_up", "medium", "open"
      "text-bg-primary"
    when "approved", "completed", "closed"
      "text-bg-success"
    when "pending", "rescheduled", "waitlisted", "security", "high", "resolved"
      "text-bg-warning"
    when "rejected", "canceled", "cancelled", "archived", "missed", "bug", "critical"
      "text-bg-danger"
    when "draft", "inactive", "hidden", "low"
      "text-bg-secondary"
    when "feature_request", "ui_ux", "in_progress"
      "text-bg-info"
    else
      "text-bg-secondary"
    end
  end

  def soft_badge_class(status)
    case status.to_s
    when "verified", "approved", "completed", "resolved", "visible", "active", "patient"
      "badge-soft-emerald"
    when "unverified", "pending", "require_validation", "high", "open", "waitlisted"
      "badge-soft-amber"
    when "critical", "bug", "security", "rejected", "canceled", "cancelled"
      "badge-soft-rose"
    when "in_progress", "admin", "ui_ux", "medium"
      "badge-soft-sky"
    when "super_admin", "staff", "feature_request"
      "badge-soft-purple"
    else
      "badge-soft-slate"
    end
  end

  def sa_nav_active(controller_segment)
    controller_path.include?(controller_segment.to_s) ? "active" : ""
  end

  def sa_breadcrumb_title
    return content_for(:breadcrumb) if content_for?(:breadcrumb)

    case controller_name
    when "dashboard"
      "Dashboard Overview"
    when "barangays"
      action_name == "show" && @barangay ? "Barangays / #{@barangay.name}" : "Registered Barangays"
    when "users"
      action_name == "show" && @user ? "Users / #{@user.full_name}" : "Users & Admins Directory"
    when "issue_reports"
      "Issue Reports Triage"
    when "testimonials"
      "Testimonials Moderation"
    when "cms"
      "Global CMS Manager"
    when "profile"
      "Edit SuperAdmin Profile"
    else
      controller_name.titleize
    end
  end

  def admin_breadcrumb_title
    return content_for(:breadcrumb) if content_for?(:breadcrumb)

    case controller_name
    when "dashboard"
      "Clinic Dashboard"
    when "appointments"
      action_name == "show" && @appointment ? "Appointments / ##{@appointment.public_uid}" : "Patient Appointments"
    when "announcements"
      if action_name == "show" && @announcement
        "Announcements / #{@announcement.name}"
      elsif action_name == "appointment_details" && @announcement
        "Announcements / #{@announcement.name} / Slot Capacity"
      else
        "Service Announcements"
      end
    when "health_programs"
      action_name == "show" && @admin_health_program ? "Health Programs / #{@admin_health_program.name}" : "Health Programs Catalog"
    when "events"
      "Community Health Events"
    when "users"
      if action_name == "show" && @user
        "Users / #{@user.full_name}"
      elsif action_name == "medical_records" && @user
        "Medical Records / #{@user.full_name}"
      elsif action_name == "edit" && @user
        "Edit User / #{@user.full_name}"
      else
        "Residents & Staff Directory"
      end
    when "cms"
      "Barangay Portal CMS"
    when "profile"
      "My Account Profile"
    else
      controller_name.titleize
    end
  end
end
