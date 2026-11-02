class Admin::EventsController < AdminController
  before_action :set_event, only: [ :update, :archive ]

  def index
    @q = Event.includes(:posted_by, :rich_text_description, :images_attachments).ransack(params[:q])
    @pagy, @events = pagy(@q.result(distinct: true).order(start_date: :desc))

    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.posted_by = current_user
    @event.barangay = current_tenant

    if @event.save
      flash[:notice] = "Event was successfully created."
    else
      flash.now[:alert] = "Event was not created."
    end
  end

  def update
    if @event.update(event_params)
      flash[:notice] = "Event was successfully updated."
    else
      flash.now[:alert] = "Event was not updated."
    end
  end

  def archive
    if @event.archived!
      flash[:notice] = "Event was successfully archived."
    else
      flash.now[:alert] = "Event was not archived."
    end
  end

  private

  def event_params
    permitted = [
      :name, :description, :start_date, :end_date, :audience, :location, :status
    ]

    permitted << { images: [] } unless params[:event][:images] == [ "" ]

    params.require(:event).permit(permitted)
  end

  def set_event
    @event = Event.find_by_public_uid(params[:id])

    if @event.nil?
      redirect_to admin_events_path, status: :see_other, alert: "Event not found."
    end
  end
end
