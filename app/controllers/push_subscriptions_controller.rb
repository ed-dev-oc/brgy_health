class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @push_subscription = current_user.push_subscriptions.new(push_subscription_params)

    if @push_subscription.save
      head :ok
    else
      render json: { error: "Unable to save subscription" }, status: 422
    end
  end

  private

  def push_subscription_params
    params.require(:push_subscription).permit(:endpoint, :p256dh, :auth)
  end
end
