class Barangay::EventsController < BarangayController
  before_action :set_event, only: [ :show ]

  def index
    @events = Event.active
  end

  def show
    @appointment = Appointment.new(Event: @Event)
  end

  private

  def set_event
    @Event = Event.find_by_public_uid(params.expect(:id))

    if @Event.nil?
      redirect_to events_path, status: :see_other, alert: "Event not found."
    end
  end
end
