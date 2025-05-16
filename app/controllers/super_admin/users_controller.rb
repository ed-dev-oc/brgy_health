class SuperAdmin::UsersController < SuperAdminController
  before_action :set_user, only: [ :show, :validated ]

  def index
    @q = User.ransack(params[:q])
    @pagy, @users = pagy(@q.result(distinct: true))
  end

  def show
  end

  def validated
    @user.flag_list.remove("require_validation")

    if @user.save
      redirect_to super_admin_users_path, status: :see_other, notice: "User removed validation."
    else
      redirect_to super_admin_users_path, status: :see_other, alert: "Error removing validation."
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
