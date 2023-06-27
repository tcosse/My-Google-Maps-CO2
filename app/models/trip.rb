class Trip < ApplicationRecord
  belongs_to :start_location, class_name: 'Location'
  belongs_to :end_location, class_name: 'Location'
  validates   :start_time,
              :end_time,
              :distance,
              :start_location_id,
              :end_location_id,
              presence: true
end
