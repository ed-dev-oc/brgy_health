class ProfileController < ApplicationController
  before_action :authenticate_user!

  layout :select_layout

  def edit
    @user = current_user
    @subdivisions = Subdivision.where(barangay_id: @user.barangay_id)
    render select_user_profile_page
  end

  def update
    @user = current_user
    @subdivisions = Subdivision.where(barangay_id: @user.barangay_id)

    if params[:new_subdivision_name].present?
      new_subdivision = Subdivision.find_or_create_by!(
        barangay_id: @user.barangay_id,
        name: params[:new_subdivision_name].strip
      )

      params[:user][:subdivision_id] = new_subdivision.id
    end

    if @user.update(user_params)
      redirect_to edit_profile_path, notice: "Profile updated successfully."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :profile, :first_name, :last_name, :middle_name, :suffix,
      :phone_number, :email, :password, :password_confirmation,
      :subdivision_id
    )
  end

  def select_layout
    if current_user&.admin?
      "layouts/admin"
    elsif current_user&.super_admin?
      "layouts/super_admin"
    else
      "layouts/application"
    end
  end

  def select_user_profile_page
    if current_user&.super_admin?
      "pages/profile"
    else
      "barangay/pages/profile"
    end
  end
end
