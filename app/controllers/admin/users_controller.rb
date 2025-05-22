# app/controllers/admin/users_controller.rb
class Admin::UsersController < AdminController
  include Pagy::Backend

  before_action :set_user, only: [ :edit, :update, :show, :toggle_status ]

  def index
    @q = User.ransack(params[:q])
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
    @user = User.find(params[:id])
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
  params.require(:user).permit(
    :email, :public_uid, :first_name, :middle_name, :last_name, :suffix, :password, :password_confirmation,
    :phone_number, :role, flag_list: []
  )
  end
end
