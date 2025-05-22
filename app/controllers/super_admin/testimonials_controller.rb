module SuperAdmin
  class TestimonialsController < SuperAdminController
    before_action :authenticate_user!
    before_action :set_testimonial, only: [:show]

    def index
      @testimonials = Testimonial.includes(:user).all

      if params[:full_name].present?
        @testimonials = @testimonials.joins(:user)
                                     .where("users.full_name ILIKE ?", "%#{params[:full_name]}%")
      end

      if params[:email].present?
        @testimonials = @testimonials.joins(:user)
                                     .where("users.email ILIKE ?", "%#{params[:email]}%")
      end

      if params[:rating].present?
        @testimonials = @testimonials.where(rating: params[:rating])
      end
    end

    def show
     
    end

    private

    def set_testimonial
      @testimonial = Testimonial.find(params[:id])
    end
  end
end
