class Barangay::AnnouncementsController < BarangayController
  before_action :set_announcement, only: [ :show ]

  def index
    @announcements = Announcement.active
  end

def show
  @appointment = Appointment.new(announcement: @announcement)

  unless @announcement.activity_logs.where(action: "viewed", user: current_user).exists?
    temp_count = @announcement.activity_logs.where(action: "viewed").select(:user_id).distinct.count

    ActivityLog.create!(
      user: current_user,
      action: "viewed",
      description: "👁️ <b>#{@announcement.name}</b> now has #{temp_count + 1} viewer#{'s' if temp_count + 1 > 1}",
      loggable: @announcement
    )
  end
end

  private

  def set_announcement
    @announcement = Announcement.find_by_public_uid(params.expect(:id))

    if @announcement.nil?
      redirect_to announcements_path, status: :see_other, alert: "Announcement not found."
    end
  end
end
