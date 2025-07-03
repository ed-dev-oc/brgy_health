class EventView < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true
end
