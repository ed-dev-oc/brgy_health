class UserCredentialChangedNotifier < ApplicationNotifier
  deliver_by :notification_broadcast, class: "DeliveryMethods::NotificationBroadcast"
  deliver_by :web_push, class: "DeliveryMethods::WebPush"
  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = :credential_changed
    config.args = -> { [ self ] }
  end

  required_param :changed_attributes

  notification_methods do
    def title
      "Account Credentials Updated"
    end

    def message
      changes = params[:changed_attributes].map do |field, change|
        if field == "password"
          "Password was updated"
        else
          from = format_value(field, change[:from])
          to = format_value(field, change[:to])
          "#{field.humanize}: \"#{from}\" → \"#{to}\""
        end
      end.compact.join(", ")

      "Your profile information has been updated: #{changes}."
    end

    def url
      Rails.application.routes.url_helpers.edit_profile_path(recipient)
    end

    def icon_class
      "bi bi-shield-lock"
    end

    private

    def format_value(field, value)
      return "none" if value.nil?

      if field == "subdivision"
        Subdivision.find_by(id: value)&.name || "Unknown"
      else
        value.to_s.strip.presence || "none"
      end
    end
  end
end
