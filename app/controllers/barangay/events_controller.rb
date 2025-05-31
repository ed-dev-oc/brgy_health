class Barangay::EventsController < BarangayController
  before_action :set_event, only: [ :show ]

  def index
    @events = Event.active
  end

  def show
  end

  private

  def set_event
    @event = Event.find_by_public_uid(params.expect(:id))

    if @event.nil?
      redirect_to events_path, status: :see_other, alert: "Event not found."
    end
  end
end
