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
    def title
      "Appointment Status Changed"
    end

    def message
      case record.status
      when "approved"
        if recipient.admin? || recipient.staff?
          "Admin / staff approved the appointment to patient #{record.patient.full_name} for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)}."
        else
          "Hello #{record.patient.full_name}, Your appointment for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)} has been approved. Please arrive on time."
        end
      when "rejected"
        if recipient.admin? || recipient.staff?
          "Admin / staff rejected the appointment to patient #{record.patient.full_name} for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)}."
        else
          "We're sorry #{record.patient.full_name}, your appointment for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)} was not approved."
        end
      when "cancelled"
        if recipient.admin? || recipient.staff?
          "Admin / staff cancelled the appointment to patient #{record.patient.full_name} for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)}."
        else
          "Hello #{record.patient.full_name}, your appointment was cancelled for #{record.announcement.name} on #{record.scheduled_at.to_formatted_s(:long)}."
        end
      else
        if recipient.admin? || recipient.staff?
          "Patient appointment status changed: #{record.patient.full_name} to #{record.announcement.name}, please check."
        else
          "Hello #{record.patient.full_name}, Your appointment status changed to #{record.announcement.name}, please check."
        end
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
