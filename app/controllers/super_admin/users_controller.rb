class SuperAdmin::UsersController < SuperAdminController
  before_action :set_user, only: [ :show, :validated ]

  def index
    @all_users_count = User.count
    @pending_validation_count = User.tagged_with([ "require_validation" ]).count
    @admins_count = User.admin.count
    @staff_count = User.staff.count
    @patients_count = User.patient.count
    @platform_staff_count = User.platform_staff.count

    base_scope = User.includes(:barangay, :taggings)
    if params[:filter] == "pending_validation"
      base_scope = base_scope.tagged_with([ "require_validation" ])
    end

    @q = base_scope.ransack(params[:q])
    @pagy, @users = pagy(@q.result(distinct: true).order(created_at: :desc))
  end

  def show
    @user.about_me_notifications.where(recipient: current_user).mark_as_read
  end

  def validated
    @user.flag_list.remove("require_validation")
    @user.flag_list.add("active")

    if @user.save
      UserMailer.admin_validated_email(@user).deliver_later
      redirect_back fallback_location: super_admin_users_path, status: :see_other, notice: "User validation approved successfully."
    else
      redirect_back fallback_location: super_admin_users_path, status: :see_other, alert: "Error updating user validation."
    end
  end

  private

  def set_user
    @user = User.find_by_public_uid(params[:id])

    if @user.nil?
      redirect_to super_admin_users_path, status: :see_other, alert: "User not found."
    end
  end
end
