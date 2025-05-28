class SuperAdmin::BarangaysController < SuperAdminController
  include Pagy::Backend
  before_action :set_barangay, only: [ :show ]

  def index
    @q = Barangay.ransack(params[:q])

    @cities = Barangay.distinct.pluck(:city).sort
    @provinces = Barangay.distinct.pluck(:province).sort
    @regions = Barangay.distinct.pluck(:region).sort

    if params[:status] == "verified"
      base_scope = Barangay.verified
    elsif params[:status] == "unverified"
      base_scope = Barangay.unverified
    else
      base_scope = Barangay.all
    end

    @pagy, @barangays = pagy(@q.result.merge(base_scope).distinct)
  end

  def show
    @admins_and_staff = @barangay.admin_and_staff
  end

  private

  def set_barangay
    @barangay = Barangay.friendly.find(params[:id])
    redirect_to super_admin_barangays_path, alert: "Barangay not found." if @barangay.nil?
  end
end
