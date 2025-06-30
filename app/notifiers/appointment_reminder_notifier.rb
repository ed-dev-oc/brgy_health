# To deliver this notification:
#
# AppointmentReminderNotifier.with(record: @post, message: "New post").deliver(User.all)

class AppointmentReminderNotifier < ApplicationNotifier
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
      "Appointment Reminder"
    end

    def message
      "Hi #{ recipient.full_name }, this is a reminder of your appointment on #{ record.announcement.name } #{ record.scheduled_at.strftime("%B %d, %Y at %I:%M %p") }. Please arrive on time."
    end

    def icon_class
      "bi bi-calendar-check"
    end

    def url
      appointment_path(record.public_uid)
    end
  end
end
