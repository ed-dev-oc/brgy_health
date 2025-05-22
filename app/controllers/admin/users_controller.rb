# app/controllers/admin/users_controller.rb
class Admin::UsersController < AdminController
  include Pagy::Backend

  before_action :set_user, only: [ :edit, :update, :show, :toggle_status ]

  def index
    @q = User.ransack(params[:q])
    @pagy, @staff_users = pagy(@q.result.order(:last_name))
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    @user.role = "staff" # enforce server-side

    if @user.save
      redirect_to admin_users_path, notice: "Staff user created successfully."
    else
      flash.now[:alert] = "There was a problem creating the user."
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @user.role == "super_admin"
      params[:user].delete(:role)
    end

    flag_str = params[:user].delete(:flag_list)
    params[:user][:flag_list] = flag_str.to_s.split(",").map(&:strip) if flag_str

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
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


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    allowed = [
      :email,
      :first_name,
      :middle_name,
      :last_name,
      :suffix,
      :password,
      :password_confirmation,
      :phone_number,
      flag_list: []
    ]

    if current_user.super_admin?
      allowed += [:role, :barangay_id, :subdivision_id, :public_uid]
    end

    params.require(:user).permit(allowed)
  end
end
