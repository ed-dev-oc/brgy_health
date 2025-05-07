class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :user, :endpoint, :p256dh, :auth, presence: true
end
