# To deliver this notification:
#
# StaticPageUpdatedNotifier.with(record: @post, message: "New post").deliver(User.all)

class StaticPageUpdatedNotifier < ApplicationNotifier
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
      ActsAsTenant.without_tenant do
        "#{record.section.titleize} Updated"
      end
    end

    def message
      ActsAsTenant.without_tenant do
        if record.barangay.nil?
          "The main system page #{record.section.titleize} has been updated."
        else
          "The page #{record.section.titleize} has been updated."
        end
      end
    end

    def icon_class
      "bi bi-gear-fill"
    end

    def url
      ActsAsTenant.without_tenant do
        if record.barangay.nil?
          root_url(subdomain: nil)
        else
          root_path
        end
      end
    end
  end
end
