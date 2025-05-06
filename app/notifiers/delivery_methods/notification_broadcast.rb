class DeliveryMethods::NotificationBroadcast < ApplicationDeliveryMethod
  # Specify the config options your delivery method requires in its config block
  required_options # :foo, :bar

  def deliver
    record.broadcast_prepend_later_to recipient.notification_channel,
      target: "notification_list",
      partial: "shared/notifications/notification",
      locals: { notification: notification }
  end
end
