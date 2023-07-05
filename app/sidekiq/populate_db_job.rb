class PopulateDbJob
  include Sidekiq::Job

  def perform(monthly_data)
    # Do something
    monthly_data['data']['timelineObjects'].each do |activity_data|
    #   if activity_data.include?('activitySegment')
    #     activity_segment = activity_data['activitySegment']
    #     start_location = Location.create!(
    #       latitude: activity_segment['startLocation']['latitudeE7'].to_i,
    #       longitude: activity_segment['startLocation']['longitudeE7'].to_i
    #     )
    #     end_location = Location.create!(
    #       latitude: activity_segment['endLocation']['latitudeE7'].to_i,
    #       longitude: activity_segment['endLocation']['longitudeE7'].to_i
    #     )
    #     Trip.create!(
    #       start_time: timestamp_to_datetime(activity_segment['duration']['startTimestamp']),
    #       end_time: timestamp_to_datetime(activity_segment['duration']['endTimestamp']),
    #       distance: activity_segment['distance'].to_i,
    #       activity_type: activity_segment['activityType'],
    #       confidence: activity_segment['confidence'],
    #       start_location:,
    #       end_location:
    #     )
    #   end
    # end
      # count += 1
    end
    puts 'the number of records is :', count
  end

  # private

  # def timestamp_to_datetime(timestamp)
  #   require 'date'
  #   DateTime.strptime(timestamp, '%Y-%m-%dT%H:%M:%S')
  # end
end
