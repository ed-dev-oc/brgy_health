class SuperAdmin::BarangaysController < SuperAdminController
  before_action :set_barangay, only: [:show, :verify, :unverify]
  include Pagy::Backend

  def index
    @q = Barangay.ransack(params[:q])
    @pagy, @barangays = pagy(@q.result.order(created_at: :desc))
  end

  def show
    @admins_and_staff = @barangay.admin_and_staff
  end

  def verify
    @barangay.update(verified: true)
    redirect_to super_admin_barangay_path(@barangay), notice: "Barangay has been verified."
  end

  def unverify
    @barangay.update(verified: false)
    redirect_to super_admin_barangay_path(@barangay), notice: "Barangay has been unverified."
  end

  private

  def set_barangay
    @barangay = Barangay.find(params[:id])
  end
end
