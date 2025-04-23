# frozen_string_literal: true

class GenerateSuperAdminUser < ActiveRecord::Migration[8.0]
  def up
    User.create!(
      email: "super_admin@test.com",
      first_name: "Super",
      last_name: "Admin",
      phone_number: "09090002154",
      password: "admin123",
      password_confirmation: "admin123",
      role: :super_admin)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
