class NewTestimonialNotifier < ApplicationNotifier
  required_param :testimonial

  deliver_by :notification_broadcast, class: "DeliveryMethods::NotificationBroadcast"
  deliver_by :web_push, class: "DeliveryMethods::WebPush"
  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = :new_testimonial_email
    config.args = -> { [ self ] }
  end

  notification_methods do
    def title
      "New Testimonial"
    end

    def message
      testimonial = params[:testimonial]
      testimonial = testimonial.first if testimonial.is_a?(Array)

      return "New testimonial submitted" unless testimonial&.user

      "New testimonial submitted by #{testimonial.user.full_name} (#{testimonial.user.email})"
    end

    def subject
      "New Testimonial Submitted"
    end

    def icon_class
      "bi bi-quote"
    end

    def url
      Rails.application.routes.url_helpers.super_admin_testimonials_path
    end
  end
end
