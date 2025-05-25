class Admin::AnnouncementsController < AdminController
  before_action :set_announcement, only: [ :show, :edit, :update, :destroy ]

  # GET /admin/announcements or /admin/announcements.json
  def index
    @q = Announcement.ransack(params[:q])
    @pagy, @announcements = pagy(@q.result(distinct: true))
  end

  # GET /admin/announcements/1 or /admin/announcements/1.json
  def show
  end

  # GET /admin/announcements/new
  def new
    @announcement = Announcement.new
    @announcement.build_health_program
  end


  # GET /admin/announcements/1/edit
  def edit
    @announcement.build_health_program unless @announcement.health_program
  end

  # POST /admin/announcements or /admin/announcements.json
  def create
    @announcement = Announcement.new(announcement_params)

    respond_to do |format|
      if @announcement.save
        format.html { redirect_to admin_announcement_path(@announcement.public_uid), notice: "Announcement was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/announcements/1 or /admin/announcements/1.json
  def update
    respond_to do |format|
      if @announcement.update(announcement_params)
        format.html { redirect_to admin_announcement_path(@announcement.public_uid), notice: "Announcement was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/announcements/1 or /admin/announcements/1.json
  def destroy
    @announcement.destroy!

    respond_to do |format|
      format.html { redirect_to admin_announcements_path, status: :see_other, notice: "Announcement was successfully destroyed." }
      format.json { head :no_content }
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
      health_program_attributes: [ :name, :description, :status ]
    ).merge(
      posted_by: current_user,
      barangay: current_tenant
    )
    end
end
