class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :authenticate_user_role
  before_action :generate_testimonial

  private

  def authenticate_user_role
    redirect_to root_path unless current_user.role == "admin" || current_user.role == "staff"
  end

  def generate_testimonial
    @testimonial = Testimonial.new if current_user.role == "admin" && current_user.testimonial.nil?
  end
end
