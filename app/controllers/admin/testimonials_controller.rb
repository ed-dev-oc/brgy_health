class Admin::TestimonialsController < AdminController
  before_action :set_testimonial, only: %i[ update ]

  def create
    @testimonial = Testimonial.new(testimonial_params)
    @testimonial.barangay = current_tenant
    @testimonial.user = current_user

    if @testimonial.save
      flash[:notice] = "Testimonial was successfully created."
    else
      flash.now[:alert] = "Testimonial was not created."
    end
  end

  def update
    if @testimonial.update(testimonial_params)
      flash[:notice] = "Testimonial was successfully updated."
    else
      flash.now[:alert] = "Testimonial was not updated."
    end
  end

  private

  def testimonial_params
    params.require(:testimonial).permit(:data, :rating)
  end

  def set_testimonial
    @testimonial = Testimonial.find(params.require(:id))

    if @testimonial.nil?
      redirect_to admin_dashboard_index_path, status: :see_other, alert: "Testimonial not found."
    end
  end
end
