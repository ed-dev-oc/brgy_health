class Barangay::AnnouncementsController < BarangayController
  before_action :set_announcement, only: [ :show ]

  def index
    @announcements = Announcement.includes(:health_program).active
  end

  def show
    @appointment = Appointment.new(announcement: @announcement)
  end

  private

  def set_announcement
    @announcement = Announcement.find_by_public_uid(params.expect(:id))

    if @announcement.nil?
      redirect_to announcements_path, status: :see_other, alert: "Announcement not found."
    end
  end
end
