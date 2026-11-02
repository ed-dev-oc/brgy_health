# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FactoryBot factories' do
  FactoryBot.factories.map(&:name).each do |factory_name|
    it "builds a valid #{factory_name} factory" do
      factory = build(factory_name)
      if factory.respond_to?(:valid?)
        expect(factory).to be_valid, -> { factory.errors.full_messages.join(', ') }
      else
        expect(factory).to be_present
      end
    end
  end
end
