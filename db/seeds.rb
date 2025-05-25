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

lao_patient = User.create!(
  email: "lao_patient@test.com",
  first_name: "Lao",
  last_name: "Patient",
  phone_number: "09093332154",
  password: "test123",
  password_confirmation: "test123",
  role: :patient,
  barangay_id: lao_barangay.id,
  subdivision_id: lao_subdivision.id
)

san_isidro_patient = User.create!(
  email: "san_isidro_patient@test.com",
  first_name: "San Isidro",
  last_name: "Patient",
  phone_number: "09094442154",
  password: "test123",
  password_confirmation: "test123",
  role: :patient,
  barangay_id: san_isidro_barangay.id,
  subdivision_id: san_isidro_subdivision.id
)

lao_health_program = HealthProgram.create!(
  barangay_id: lao_barangay.id,
  name: "Free Vaccination Drive",
  description: "Description for Free Vaccination Drive",
  status: 1
)

san_isidro_health_program = HealthProgram.create!(
  barangay_id: san_isidro_barangay.id,
  name: "Free Vaccination Drive",
  description: "Description for Free Vaccination Drive",
  status: 1
)

lao_announcement = Announcement.create!(
  barangay_id: lao_barangay.id,
  posted_by_id: lao_admin.id,
  health_program_id: lao_health_program.id,
  name: "Free Vaccination Drive",
  description: "<h1>Bold Title</h1><p>This is a <strong>rich</strong> description.</p>",
  start_date: Time.current.tomorrow.change(hour: 8, minute: 0, second: 0),
  end_date: Time.current.next_week.change(hour: 17, minute: 0, second: 0),
  open_time: Time.current.tomorrow.change(hour: 8, min: 0, sec: 0),
  close_time: Time.current.next_week.change(hour: 17, min: 0, sec: 0),
  location: "Barangay Hall",
  max_patients: 100,
  audience: "All Residents",
  status: 1
)

san_isidro_announcement = Announcement.create!(
  barangay_id: san_isidro_barangay.id,
  posted_by_id: san_isidro_admin.id,
  health_program_id: san_isidro_health_program.id,
  name: "Free Vaccination Drive",
  description: "<h1>Bold Title</h1><p>This is a <strong>rich</strong> description.</p>",
  start_date: Time.current.tomorrow.change(hour: 8, minute: 0, second: 0),
  end_date: Time.current.next_week.change(hour: 17, minute: 0, second: 0),
  open_time: Time.current.tomorrow.change(hour: 8, min: 0, sec: 0),
  close_time: Time.current.next_week.change(hour: 17, min: 0, sec: 0),
  location: "Barangay Hall",
  max_patients: 100,
  audience: "All Residents",
  status: 1
)

lao_patient_appointment = Appointment.create!(
  barangay_id: lao_barangay.id,
  announcement_id: lao_announcement.id,
  health_worker_id: lao_admin.id,
  patient_id: lao_patient.id,
  scheduled_at: lao_announcement.start_date.change(hour: 8, minute: 0, second: 0),
  reason: "Vaccination Drive",
  notes: nil,
  follow_up_id: nil
)

Appointment.create!(
  barangay_id: lao_barangay.id,
  announcement_id: lao_announcement.id,
  health_worker_id: lao_admin.id,
  patient_id: lao_patient.id,
  scheduled_at: lao_announcement.start_date.change(hour: 8, minute: 0, second: 0),
  reason: "Vaccination Drive Follow Up",
  notes: nil,
  follow_up_id: lao_patient_appointment.id
)

san_isidro_patient_appointment = Appointment.create!(
  barangay_id: san_isidro_barangay.id,
  announcement_id: san_isidro_announcement.id,
  health_worker_id: san_isidro_admin.id,
  patient_id: san_isidro_patient.id,
  scheduled_at: san_isidro_announcement.start_date.change(hour: 8, minute: 0, second: 0),
  reason: "Vaccination Drive",
  notes: nil,
  follow_up_id: nil
)

Appointment.create!(
  barangay_id: san_isidro_barangay.id,
  announcement_id: san_isidro_announcement.id,
  health_worker_id: san_isidro_admin.id,
  patient_id: san_isidro_patient.id,
  scheduled_at: san_isidro_announcement.start_date.change(hour: 8, minute: 0, second: 0),
  reason: "Vaccination Drive Follow Up",
  notes: nil,
  follow_up_id: san_isidro_patient_appointment.id
)

User.create!(
  email: "juan.delacruz@example.com",
  first_name: "Juan",
  middle_name: "Santos",
  last_name: "Dela Cruz",
  suffix: "Jr.",
  phone_number: "09171234567",
  role: "staff",  # or "admin", "patient", etc.
  barangay_id: 1,  # Assumes you have a barangay with ID 1
  subdivision_id: 1,  # Assumes you have a subdivision with ID 1
  flag_list: [ "active" ],  # if flag_list is using something like `acts_as_flaggable`
  password: "password123",
  password_confirmation: "password123"
)

User.create!(
  email: "maria.reyes@example.com",
  first_name: "Maria",
  middle_name: "Lopez",
  last_name: "Reyes",
  suffix: "",
  phone_number: "09181234567",
  role: "staff",
  barangay_id: 1,
  subdivision_id: 1,
  flag_list: [ "active" ],
  password: "password123",
  password_confirmation: "password123"
)

User.create!(
  email: "carlos.santos@example.com",
  first_name: "Carlos",
  middle_name: "Diaz",
  last_name: "Santos",
  suffix: "Sr.",
  phone_number: "09221234567",
  role: "staff",
  barangay_id: 1,
  subdivision_id: 1,
  flag_list: [ "inactive" ],
  password: "password123",
  password_confirmation: "password123"
)

User.create!(
  email: "ana.torres@example.com",
  first_name: "Ana",
  middle_name: "Garcia",
  last_name: "Torres",
  suffix: "",
  phone_number: "09331234567",
  role: "staff",
  barangay_id: 1,
  subdivision_id: 1,
  flag_list: [ "active" ],
  password: "password123",
  password_confirmation: "password123"
)

User.create!(
  email: "roberto.cruz@example.com",
  first_name: "Roberto",
  middle_name: "Marcos",
  last_name: "Cruz",
  suffix: "",
  phone_number: "09441234567",
  role: "staff",
  barangay_id: 1,
  subdivision_id: 1,
  flag_list: [ "inactive" ],
  password: "password123",
  password_confirmation: "password123"
)
