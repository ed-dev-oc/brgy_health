# To deliver this notification:
#
# NewTestimonialNotifier.with(record: @post, message: "New post").deliver(User.all)

class NewTestimonialNotifier < ApplicationNotifier
  # Add your delivery methods
  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  # end
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end

  # Add required params
  #
  # required_param :message
  deliver_by :notification_broadcast, class: "DeliveryMethods::NotificationBroadcast"
  deliver_by :web_push, class: "DeliveryMethods::WebPush"
  deliver_by :email, mailer: "UserMailer", method: :new_testimonial_email

  required_param :testimonial

  notification_methods do
    def message
      testimonial = params[:testimonial]
      return "New testimonial submitted" unless testimonial&.user

      user = testimonial.user
      "New testimonial submitted by #{user.full_name} (#{user.email})."
    end

    def subject
      "New Testimonial Submitted"
    end

    def url
      Rails.application.routes.url_helpers.super_admin_testimonials_path
    end
  end
end
