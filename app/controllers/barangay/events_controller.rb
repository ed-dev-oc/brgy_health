class Barangay::EventsController < BarangayController
  before_action :set_event, only: [:show]

  def index
    @events = Event.active
  end

  def show
    log_event_view if @event.present?
  end

  private

  def set_event
    @event = Event.find_by_public_uid(params.expect(:id))

    if @event.nil?
      redirect_to events_path, status: :see_other, alert: "Event not found."
    end
  end

  def log_event_view
    if current_user
      unless @event.views.exists?(user_id: current_user.id)
        @event.views.create(user: current_user, ip_address: request.remote_ip)
      end
    else

      unless @event.views.exists?(user_id: nil, ip_address: request.remote_ip)
        @event.views.create(user: nil, ip_address: request.remote_ip)
      end
    end
  end
end
