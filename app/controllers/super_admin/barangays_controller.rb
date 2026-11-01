class SuperAdmin::BarangaysController < SuperAdminController
  include Pagy::Backend
  before_action :set_barangay, only: [ :show ]

  def index
    @q = Barangay.ransack(params[:q])

    @cities = Barangay.distinct.pluck(:city).compact.sort
    @provinces = Barangay.distinct.pluck(:province).compact.sort
    @regions = Barangay.distinct.pluck(:region).compact.sort

    @verified_barangay_ids = Barangay.verified.pluck(:id).to_set
    @all_barangays_count = Barangay.count
    @verified_barangays_count = @verified_barangay_ids.size
    @unverified_barangays_count = [ @all_barangays_count - @verified_barangays_count, 0 ].max

    if params[:status] == "verified"
      base_scope = Barangay.where(id: @verified_barangay_ids.to_a)
    elsif params[:status] == "unverified"
      base_scope = Barangay.where.not(id: @verified_barangay_ids.to_a)
    else
      base_scope = Barangay.all
    end

    @pagy, @barangays = pagy(@q.result.merge(base_scope).distinct.order(created_at: :desc))
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
