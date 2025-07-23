class Admin::UsersController < AdminController
  include Pagy::Backend

  before_action :set_user, only: [ :edit, :update, :show, :toggle_status, :medical_records ]

  def index
    @q = User.includes(:taggings).ransack(params[:q])
    users = @q.result

    if params[:status].present?
      users = users.tagged_with(params[:status], on: :flags)
    end

    if params[:role].present?
      users = users.where(role: params[:role])
    end

    @pagy, @staff_users = pagy(users.order(:last_name))
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.role = "staff"

    if @user.save
      redirect_to admin_users_path, notice: "Staff user created successfully."
    else
      flash.now[:alert] = "There was a problem creating the user."
      render :index, status: :unprocessable_entity
    end
  end

  def update
    flag_str = params[:user].delete(:flag_list)
    params[:user][:flag_list] = flag_str.to_s.split(",").map(&:strip) if flag_str

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

    def show
    @versions = @user.versions.reorder(created_at: :desc)

    @processed_versions = @versions.map do |version|
      changeset = YAML.safe_load(
        version.object_changes || "",
        permitted_classes: [Time, Date, Symbol, ActiveSupport::TimeWithZone],
        aliases: true
      )&.symbolize_keys || {}

      display_changes = changeset.map do |field, (old_val, new_val)|
        next if %w[
          updated_at
          password
          password_digest
          id
          user_id
          flag_list
        ].include?(field.to_s)

        case field.to_s
        when "role"
          {
            field: "Role",
            old: User.roles.key(old_val.to_i) || "Unknown",
            new: User.roles.key(new_val.to_i) || "Unknown",
            who: User.find_by(id: version.whodunnit)&.full_name || "System",
            time: version.created_at
          }
        when "subdivision_id"
          {
            field: "Subdivision",
            old: Subdivision.find_by(id: old_val)&.name || "N/A",
            new: Subdivision.find_by(id: new_val)&.name || "N/A",
            who: User.find_by(id: version.whodunnit)&.full_name || "System",
            time: version.created_at
          }
        when "barangay_id"
          {
            field: "Barangay",
            old: Barangay.find_by(id: old_val)&.name || "N/A",
            new: Barangay.find_by(id: new_val)&.name || "N/A",
            who: User.find_by(id: version.whodunnit)&.full_name || "System",
            time: version.created_at
          }
        when "image_updated_at"
          {
            field: "Profile image",
            old: old_val ? old_val.strftime("%B %d, %Y %I:%M %p") : "N/A",
            new: new_val ? new_val.strftime("%B %d, %Y %I:%M %p") : "N/A",
            who: User.find_by(id: version.whodunnit)&.full_name || "System",
            time: version.created_at
          }
        when "encrypted_password"
          {
            field: "Password",
            message: "Password was changed.",
            who: User.find_by(id: version.whodunnit)&.full_name || "System",
            time: version.created_at  
          }
        else
          {
            field: field.to_s.humanize,
            old: old_val,
            new: new_val,
            who: User.find_by(id: version.whodunnit)&.full_name || "System",
            time: version.created_at
          }
        end
      end.compact

      { changes: display_changes }
    end
  end


  def toggle_status
    @user = User.find(params[:id])

    if @user.flag_list.include?("active")
      @user.flag_list.remove("active")
      @user.flag_list.add("inactive")
    else
      @user.flag_list.remove("inactive")
      @user.flag_list.add("active")
    end

    if @user.save
      redirect_to admin_users_path, notice: "User status updated."
    else
      redirect_to admin_users_path, alert: "Failed to update user status."
    end
  end

  def medical_records
    @appointments = Appointment
    .includes(:health_worker)
    .where(patient_id: @user.id)
    .order(scheduled_at: :desc)
  end

  private

  def set_user
     @user = User.find_by(public_uid: params[:id]) || User.find_by(id: params[:id])
  end

  def user_params
    permitted = [
      :email, :public_uid, :first_name, :middle_name, :last_name, :suffix,
      :password, :password_confirmation, :phone_number
    ]

    if current_user&.super_admin? || current_user&.admin?
      permitted << :role
      permitted << { flag_list: [] }
    end

    params.require(:user).permit(permitted)
  end
end
