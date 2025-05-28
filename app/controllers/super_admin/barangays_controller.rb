class SuperAdmin::BarangaysController < SuperAdminController
  before_action :set_barangay, only: [ :show ]

  def index
    @q = Barangay.ransack(params[:q])
    @pagy, @barangays = pagy(@q.result(distinct: true))
  end

  def show
    @admins_and_staff = @barangay.admin_and_staff
  end

  private

  def set_barangay
    @barangay = Barangay.friendly.find(params[:id])
    if @barangay.nil?
      redirect_to super_admin_barangays_path, alert: "Barangay not found."
    end
  end
end
