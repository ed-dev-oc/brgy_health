module SuperAdmin
  class TestimonialsController < SuperAdminController
    include Pagy::Backend
    before_action :authenticate_user!
    before_action :set_testimonial, only: [ :show ]

    def index
      @testimonials = Testimonial.includes(:user).all

      if params[:full_name].present?
        @testimonials = @testimonials.joins(:user)
                                    .where("CONCAT_WS(' ', users.first_name, users.middle_name, users.last_name, users.suffix) ILIKE ?", "%#{params[:full_name]}%")
      end

      if params[:email].present?
        @testimonials = @testimonials.joins(:user)
                                    .where("users.email ILIKE ?", "%#{params[:email]}%")
      end

      if params[:rating].present?
        @testimonials = @testimonials.where(rating: params[:rating])
      end

      case params[:year_filter]
      when "this_year"
        @testimonials = @testimonials.where(created_at: Time.current.beginning_of_year..Time.current.end_of_year)
      when "last_year"
        last_year = Time.current.year - 1
        @testimonials = @testimonials.where(created_at: Date.new(last_year).beginning_of_year..Date.new(last_year).end_of_year)
      end

      @pagy, @testimonials = pagy(@testimonials.order(created_at: :desc))

      current_user.notifications.where(type: "NewTestimonialNotifier::Notification").mark_as_read
    end



    private

    def set_testimonial
      @testimonial = Testimonial.includes(:user, :barangay).find(params[:id])
    end
  end
end
