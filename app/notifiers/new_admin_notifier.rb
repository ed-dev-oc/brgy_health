# To deliver this notification:
#
# NewAdminNotifier.with(record: @post, message: "New post").deliver(User.all)

class NewAdminNotifier < ApplicationNotifier
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
  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = :new_admin_email
    config.args = -> { [ self ] }
  end

  notification_methods do
    def message
      "New Admin Registration from barangay #{record.barangay.name}"
    end

    def url
      super_admin_user_path(record.public_uid)
    end
  end
end
