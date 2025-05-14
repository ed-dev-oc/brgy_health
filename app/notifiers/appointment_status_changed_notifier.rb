# To deliver this notification:
#
# AppointmentStatusChangedNotifier.with(record: @post, message: "New post").deliver(User.all)

class AppointmentStatusChangedNotifier < ApplicationNotifier
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
    def message
      case record.status
      when "approved"
        "Your appointment for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)} has been approved. Please arrive on time."
      when "rejected"
        "We're sorry, your appointment for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)} was not approved."
      when "cancelled"
        "The patient cancelled their appointment for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)}."
      else
        if recipient.admin? || recipient.staff?
          "Patient appointment status changed: #{record.patient.full_name} to #{record.announcement.name}."
        else
          "Your appointment status changed to #{record.announcement.name}, please check."
        end
      end
    end

    def url
      if recipient.admin? || recipient.staff?
        admin_appointment_path(record.public_uid)
      else
        appointment_path(record.id)
      end
    end
  end
end
