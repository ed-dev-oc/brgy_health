# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    user = find_user_by_email

    if requires_validation?(user)
      handle_validation_required
    elsif unauthorized_super_admin_access?(user)
      handle_unauthorized_access
    else
      super
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def find_user_by_email
    User.find_by(email: params[:user][:email])
  end

  def requires_validation?(user)
    user&.flag_list&.include?("require_validation")
  end

  def unauthorized_super_admin_access?(user)
    user&.role != "super_admin" && ActsAsTenant.current_tenant.blank?
  end

  def handle_validation_required
    flash[:alert] = "Your account requires validation. Please check your email for further instructions."
    redirect_to new_user_session_path
  end

  def handle_unauthorized_access
    flash[:alert] = "Only Super Admin can sign in to this page."
    redirect_to new_user_session_path
  end
end
