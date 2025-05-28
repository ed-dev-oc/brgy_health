# To deliver this notification:
#
# FollowUpCheckUpNotifier.with(record: @post, message: "New post").deliver(User.all)

class FollowUpCheckUpNotifier < ApplicationNotifier
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
      "Follow Up Check Up"
    end

    def message
      "Hi #{ recipient.full_name }, this is a reminder of your follow-up check-up on #{ record.scheduled_at.strftime("%B %d, %Y at %I:%M %p") }. Please arrive on time."
    end

    def icon_class
      "bi bi-heart-pulse"
    end

    def url
      appointments_path
    end
  end
end
