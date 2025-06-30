class Barangay::AnnouncementsController < BarangayController
  before_action :set_announcement, only: [:show]

  def index
    @announcements = Announcement.includes(:health_program).active
  end

  def show
    @appointment = Appointment.new(announcement: @announcement)

    log_announcement_view if @announcement.present?
  end

  private

  def set_announcement
    @announcement = Announcement.find_by_public_uid(params[:id])

    if @announcement.nil?
      redirect_to announcements_path, status: :see_other, alert: "Announcement not found."
    end
  end

  def log_announcement_view
    ip = request.remote_ip

    unless @announcement.views.exists?(ip_address: ip)
      @announcement.views.create(user: current_user, ip_address: ip)
    end
  end
end
