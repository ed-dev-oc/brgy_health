class ApplicationController < ActionController::Base
  include Pagy::Backend
  include PaperTrail::Rails::Controller

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_paper_trail_whodunnit

  def user_for_paper_trail
    current_user.try(:id)
  end

  set_current_tenant_through_filter
  before_action :set_current_tenant

  private

  def set_current_tenant
    # Skip setting tenant if it's the main domain
    return if request.subdomain.blank? || request.subdomain == "www"

    barangay = Barangay.find_by(subdomain: request.subdomain)
    if barangay
      ActsAsTenant.current_tenant = barangay
    else
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end
end
