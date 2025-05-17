class SuperAdmin::ProfileController < ApplicationController
  before_action :authenticate_user!
  layout "layouts/super_admin"
  def edit
    @user = current_user
    render "pages/profile"
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to edit_super_admin_profile_path, notice: "Profile updated successfully."
    else
      render "pages/profile"
    end
  end

  private

  def user_params
    params.require(:user).permit(:profile, :first_name, :last_name,
      :phone_number, :email, :password, :password_confirmation)
  end
end
