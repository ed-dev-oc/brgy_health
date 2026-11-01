# To deliver this notification:
#
# NewAppointmentNotifier.with(record: @post, message: "New post").deliver(User.all)

class NewAppointmentNotifier < ApplicationNotifier
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
  # deliver_by :notification_broadcast do |config|
  #   config.class = "DeliveryMethods::NotificationBroadcast"
  # end

  # Add required params
  #
  # required_param :message

  deliver_by :notification_broadcast, class: "DeliveryMethods::NotificationBroadcast"
  deliver_by :web_push, class: "DeliveryMethods::WebPush"

  notification_methods do
    def title
      "New Appointment"
    end

    def message
      return "New appointment" unless record&.patient && record&.announcement

      "New appointment: #{record.patient.full_name} on #{record.announcement.name} at #{record.scheduled_at.to_formatted_s(:long)}."
    end

    def icon_class
      "bi bi-calendar-check"
    end

    def url
      return "#" unless record&.public_uid

      admin_appointment_path(record.public_uid)
    end
  end
end
