class Barangay::AnnouncementsController < BarangayController
  before_action :set_announcement, only: [ :show ]

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
  if current_user
    unless @announcement.views.exists?(user_id: current_user.id)
      @announcement.views.create(user: current_user, ip_address: request.remote_ip)
    end
  else
    # fallback for guests (tracked by IP)
    unless @announcement.views.exists?(user_id: nil, ip_address: request.remote_ip)
      @announcement.views.create(user: nil, ip_address: request.remote_ip)
    end
  end
end

end
