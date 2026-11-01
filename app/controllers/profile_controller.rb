class ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tenant, unless: -> { current_user.super_admin? }

  layout :select_layout

  def edit
    @user = current_user

    @subdivisions = if @user.super_admin?
      ActsAsTenant.without_tenant { Subdivision.none }
    else
      Subdivision.where(barangay_id: @user.barangay_id)
    end

    render select_user_profile_page
  end

  def update
    @user = current_user

    @subdivisions = if @user.super_admin?
      ActsAsTenant.without_tenant { Subdivision.none }
    else
      Subdivision.where(barangay_id: @user.barangay_id)
    end

    if params[:new_subdivision_name].present?
      new_subdivision = ActsAsTenant.without_tenant do
        Subdivision.find_or_create_by!(
          barangay_id: @user.barangay_id,
          name: params[:new_subdivision_name].strip
        )
      end
      params[:user][:subdivision_id] = new_subdivision.id
    end

    if @user.update(user_params)
      redirect_to edit_profile_path(@user), notice: "Profile updated successfully."
    else
      render select_user_profile_page, status: :unprocessable_entity
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
    if current_user&.admin? || current_user&.staff?
      "admin"
    elsif current_user&.super_admin?
      "super_admin"
    else
      "barangay"
    end
  end

  def select_user_profile_page
    if current_user&.super_admin?
      "pages/profile"
    else
      "barangay/pages/profile"
    end
  end

  def set_tenant
    ActsAsTenant.current_tenant = current_user.barangay
  end
end
