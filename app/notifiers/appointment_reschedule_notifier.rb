# To deliver this notification:
#
# AppointmentRescheduleNotifier.with(record: @post, message: "New post").deliver(User.all)

class AppointmentRescheduleNotifier < ApplicationNotifier
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

  notification_methods do
    def title
      "Appointment Reschedule"
    end

    def message
      if recipient.admin? || recipient.staff?
        "Patient #{ record.patient.full_name } has rescheduled their #{ record.announcement.name } appointment to #{ record.scheduled_at.to_formatted_s(:long) }."
      else
        " Hello #{ record.patient.full_name }, your appointment for #{ record.announcement.name } has been rescheduled by the admin to #{ record.scheduled_at.to_formatted_s(:long) }."
      end
    end

    def icon_class
      "bi bi-calendar-check"
    end

    def url
      if recipient.admin? || recipient.staff?
        admin_appointment_path(record.public_uid)
      else
        appointment_path(record.public_uid)
      end
    end
  end
end
