class Admin::AnnouncementsController < AdminController
  before_action :set_announcement, only: [ :show, :update, :archive ]

  # GET /admin/announcements or /admin/announcements.json
  def index
    @q = Announcement.ransack(params[:q])
    @pagy, @announcements = pagy(@q.result(distinct: true))
    @announcement = Announcement.new
    @announcement.build_health_program
  end

  # GET /admin/announcements/1 or /admin/announcements/1.json
  def show
  end

  # POST /admin/announcements or /admin/announcements.json
  def create
    @announcement = Announcement.new(announcement_params)

    if @announcement.save
      flash[:notice] = "Announcement was successfully created."
    else
      flash[:alert] = "Announcement was not created."
    end
  end

  # PATCH/PUT /admin/announcements/1 or /admin/announcements/1.json
  def update
    if @announcement.update(announcement_params)
      flash[:notice] = "Announcement was successfully updated."
    else
      flash[:alert] = "Announcement was not updated."
    end
  end

  def archive
    if @announcement.archived!
      flash[:notice] = "Announcement was successfully archived."
    else
      flash.now[:alert] = "Announcement was not archived."
    end
  end

  private

  def set_announcement
    @announcement = Announcement.find_by_public_uid(params.expect(:id))

    if @announcement.nil?
      redirect_to admin_announcements_path, status: :see_other, alert: "Announcement not found."
    end
  end

  # Only allow a list of trusted parameters through.
  def announcement_params
    params.require(:announcement).permit(
      :name,
      :description,
      :start_date,
      :end_date,
      :open_time,
      :close_time,
      :location,
      :max_patients,
      :audience,
      :status,
      :health_program_id,
      images: [],
      health_program_attributes: [ :name, :description, :status ]
    ).merge(
      posted_by: current_user,
      barangay: current_tenant
    )
  end
end
