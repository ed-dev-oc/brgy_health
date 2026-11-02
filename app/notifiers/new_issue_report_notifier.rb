# To deliver this notification:
#
# NewIssueReportNotifier.with(record: @post, message: "New post").deliver(User.all)

class NewIssueReportNotifier < ApplicationNotifier
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
      "New Issue Report"
    end

    def message
      "New Issue Reported: [#{record.title}] (ID: #{record.public_uid})"
    end

    def icon_class
      "bi bi-exclamation-triangle"
    end

    def url
      super_admin_issue_reports_path
    end
  end
end
