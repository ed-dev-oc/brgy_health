# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    # super

    build_resource({})
    resource.build_barangay

    respond_with resource
  end

  # POST /resource
  def create
    super do |resource|
      if ActsAsTenant.current_tenant.present?
        resource.barangay = ActsAsTenant.current_tenant
        resource.role = :patient
      else
        resource.role = :admin
      end

      resource.save
      resource.build_barangay if resource.barangay.nil? && ActsAsTenant.current_tenant.blank?

      # if resource.role == :admin
      #   sign_out resource
      # end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    keys = [ :email, :first_name, :middle_name, :last_name, :suffix, :password, :password_confirmation ]
    keys << { barangay_attributes: [ :name, :region, :province, :city ] } unless ActsAsTenant.current_tenant.present?

    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    unless ActsAsTenant.current_tenant.present?
      sign_out(resource)
      flash[:notice] = "Your account has been created. Please wait for an email to be sent."
    end

    super(resource)
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
