# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


lao_barangay = Barangay.create!(
  name: "Lao",
  region: "Region VIII (Eastern Visayas)",
  province: "Leyte",
  city: "Ormoc"
)

san_isidro_barangay = Barangay.create!(
  name: "San Isidro",
  region: "Region VIII (Eastern Visayas)",
  province: "Leyte",
  city: "Ormoc"
)

lao_subdivision = Subdivision.create!(
  barangay_id: lao_barangay.id,
  name: "Purok One"
)

san_isidro_subdivision = Subdivision.create!(
  barangay_id: san_isidro_barangay.id,
  name: "Purok One"
)

lao_admin = User.create!(
  email: "lao_admin@test.com",
  first_name: "Lao",
  last_name: "Admin",
  phone_number: "09091112154",
  password: "admin123",
  password_confirmation: "admin123",
  role: :admin,
  barangay_id: lao_barangay.id,
  subdivision_id: lao_subdivision.id
)
lao_admin.flag_list.remove("require_validation")
lao_admin.save

san_isidro_admin = User.create!(
  email: "san_isidro_admin@test.com",
  first_name: "San Isidro",
  last_name: "Admin",
  phone_number: "09092222154",
  password: "admin123",
  password_confirmation: "admin123",
  role: :admin,
  barangay_id: san_isidro_barangay.id,
  subdivision_id: san_isidro_subdivision.id
)
san_isidro_admin.flag_list.remove("require_validation")
san_isidro_admin.save