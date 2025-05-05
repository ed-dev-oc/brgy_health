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
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end

  # Add required params
  #
  # required_param :message

  deliver_by :database

  notification_methods do
    def message
      "New appointment: #{record.patient.full_name} on #{record.announcement.name} at #{record.scheduled_at.to_formatted_s(:long)}."
    end

    def url
      admin_appointment_path(record.public_uid)
    end
  end
end
