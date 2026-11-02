# To deliver this notification:
#
# NewEventNotifier.with(record: @post, message: "New post").deliver(User.all)

class NewEventNotifier < ApplicationNotifier
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
      "New Event"
    end

    def message
      "Something new just dropped! See our upcoming event."
    end

    def icon_class
      "bi bi-calendar-event"
    end

    def url
      root_path
    end
  end
end
