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
    user_versions = @user.versions

    appointment_versions = @user.appointments.includes(:versions).flat_map(&:versions).select do |v|
      v.event == "create"
    end

    all_versions = (user_versions + appointment_versions).sort_by(&:created_at).reverse

    @processed_versions = all_versions.map do |version|
      changes = []
      who = User.find_by(id: version.whodunnit)&.full_name || "System"
      time = version.created_at

      if version.event == "create" && version.item_type == "Appointment"
        changes << {
          field: "Appointment",
          message: "Appointment booked",
          who: who,
          time: time
        }
      else
        changeset = YAML.safe_load(
          version.object_changes || "",
          permitted_classes: [Time, Date, Symbol, ActiveSupport::TimeWithZone],
          aliases: true
        )&.symbolize_keys || {}

        changeset.each do |field, (old_val, new_val)|
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
            changes << {
              field: "Role",
              old: User.roles.key(old_val.to_i) || "Unknown",
              new: User.roles.key(new_val.to_i) || "Unknown",
              who: who,
              time: time
            }
          when "subdivision_id"
            changes << {
              field: "Subdivision",
              old: Subdivision.find_by(id: old_val)&.name || "N/A",
              new: Subdivision.find_by(id: new_val)&.name || "N/A",
              who: who,
              time: time
            }
          when "barangay_id"
            changes << {
              field: "Barangay",
              old: Barangay.find_by(id: old_val)&.name || "N/A",
              new: Barangay.find_by(id: new_val)&.name || "N/A",
              who: who,
              time: time
            }
          when "image_updated_at"
            changes << {
              field: "Profile image",
              message: "Profile image updated",
              who: who,
              time: time
            }
          when "encrypted_password"
            changes << {
              field: "Password",
              message: "Password was changed",
              who: who,
              time: time
            }
          else
            changes << {
              field: field.to_s.humanize,
              old: old_val,
              new: new_val,
              who: who,
              time: time
            }
          end
        end
      end

      { changes: changes }
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

