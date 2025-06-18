class Admin::HealthProgramsController < AdminController
  include Pagy::Backend
  before_action :set_admin_health_program, only: %i[ show edit update destroy ]

  # GET /admin/health_programs or /admin/health_programs.json
  def index
    @query = params[:q]&.strip
    scope = if @query.present?
      HealthProgram.where("name ILIKE :q OR description ILIKE :q", q: "%#{@query}%")
    else
      HealthProgram.all
    end

    @pagy, @admin_health_programs = pagy(scope)
  end

  # GET /admin/health_programs/1 or /admin/health_programs/1.json
  def show
    @activity_logs = @admin_health_program.activity_logs.includes(:user).order(created_at: :desc)
  end

  # GET /admin/health_programs/new
  def new
    @admin_health_program = HealthProgram.new
  end

  # GET /admin/health_programs/1/edit
  def edit
  end

  # POST /admin/health_programs or /admin/health_programs.json
  def create
    @admin_health_program = HealthProgram.new(admin_health_program_params)

    respond_to do |format|
      if @admin_health_program.save
        # Log the creation action
        ActivityLog.create!(
          user: current_user,
          action: "created",
          description: "Created health program '#{@admin_health_program.name}'",
          loggable: @admin_health_program
        )
        # Redirect or render based on the request format
        format.html { redirect_to [ :admin, @admin_health_program ], notice: "Health program was successfully created." }
        format.json { render :show, status: :created, location: [ :admin, @admin_health_program ] }

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_health_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/health_programs/1 or /admin/health_programs/1.json
  def update
    respond_to do |format|
      if @admin_health_program.update(admin_health_program_params)
        # Log the update action
        ActivityLog.create!(
          user: current_user,
          action: "updated",
          description: @admin_health_program.generate_change_log_description,
          loggable: @admin_health_program
        )
        format.html { redirect_to [ :admin, @admin_health_program ], notice: "Health program was successfully updated." }
        format.json { render :show, status: :ok, location: [ admin, @admin_health_program ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin_health_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/health_programs/1 or /admin/health_programs/1.json
  def destroy
    @admin_health_program.destroy!
    # Log the destruction action
    ActivityLog.create!(
      user: current_user,
      action: "destroyed",
      description: "Destroyed health program '#{@admin_health_program.name}'",
      loggable: @admin_health_program
    )

    respond_to do |format|
      format.html { redirect_to admin_health_programs_path, status: :see_other, notice: "Health program was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_health_program
      @admin_health_program = HealthProgram.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def admin_health_program_params
      params.require(:health_program).permit(:barangay_id, :name, :description, :status)
    end
end
