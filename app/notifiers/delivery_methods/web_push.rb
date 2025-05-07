class DeliveryMethods::WebPush < ApplicationDeliveryMethod
  # Specify the config options your delivery method requires in its config block
  required_options # :foo, :bar

  def deliver
    recipient.push_subscriptions.each do |subscription|
      web_push_title = "Hello #{ recipient.full_name }"
      web_push_message = notification.message
      web_push_path = notification.url

      send_web_push(subscription, payload(web_push_title, web_push_message, web_push_path))
    end
  end

  private

  def payload(title, message, path)
    {
      title: title,
      options: {
        body: message,
        icon: "/icon.png",
        data: {
          path: path
        }
      }
    }.to_json
  end

  def send_web_push(subscription, message)
    begin
      WebPush.payload_send(
        message: message,
        endpoint: subscription.endpoint,
        p256dh: subscription.p256dh,
        auth: subscription.auth,
        vapid: {
          subject: "mailto:sender@example.com",
          public_key: Rails.application.credentials.dig(:web_push, :public_key),
          private_key: Rails.application.credentials.dig(:web_push, :private_key)
        },
        ssl_timeout: 5, # optional value for Net::HTTP#ssl_timeout=
        open_timeout: 5, # optional value for Net::HTTP#open_timeout=
        read_timeout: 5 # optional value for Net::HTTP#read_timeout=
      )
    rescue WebPush::Error => e
      subscription.destroy if e.message.include?("410 Gone")
    end
  end
end
