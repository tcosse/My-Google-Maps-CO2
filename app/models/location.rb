class Location < ApplicationRecord
  has_many :location_starting_trips, class_name: 'Trip', foreign_key: 'start_location_id'
  has_many :location_ending_trips, class_name: 'Trip', foreign_key: 'end_location_id'
  validates :longitude, :latitude, presence: true
end
