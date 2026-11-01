# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc "Manually apply seeds in production (bypasses production safety guard)"
    task manual: :environment do
      ENV["ALLOW_PRODUCTION_SEEDS"] = "true"
      puts "Manually executing db:seed in #{Rails.env}..."
      Rails.application.load_seed
      puts "Done applying seeds."
    end

    desc "Alias for db:seed:manual"
    task force: :manual
  end
end
