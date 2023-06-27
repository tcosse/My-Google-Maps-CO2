require 'zip'
require 'json'
require 'pp'
require 'benchmark'

class UploadFileController < ApplicationController

  def process_takeout
    puts 'uploadfile', Benchmark.measure {
      # Upload the file to google cloud using active storage
      current_user.takeout_file.attach(params[:takeout_file])
    }
    puts 'Parsing and inserting data to db', Benchmark.measure {
      # Read Zip Data and populate DataBase using Jsons
      takeout_file = params[:takeout_file].tempfile
      @compiled_data = read_zip_file(takeout_file)
      insert_into_db(@compiled_data)
    }
  end

  private

  def insert_into_db(compiled_data)
    compiled_data.each do |monthly_data|
      puts "Adding Json data of month #{monthly_data[:filename]} to DB"
      monthly_data[:data]['timelineObjects'].each do |activities|
        if activities.include?('activitySegment')
          # Store hash with activitySegment data in activity_data variable
          activity_data = activities['activitySegment']
          start_location = Location.create!(
            latitude: activity_data['startLocation']['latitudeE7'].to_i,
            longitude: activity_data['startLocation']['longitudeE7'].to_i
          )
          end_location = Location.create!(
            latitude: activity_data['endLocation']['latitudeE7'].to_i,
            longitude: activity_data['endLocation']['longitudeE7'].to_i
          )
          Trip.create!(
            start_time: timestamp_to_datetime(activity_data['duration']['startTimestamp']),
            end_time: timestamp_to_datetime(activity_data['duration']['endTimestamp']),
            distance: activity_data['distance'].to_i,
            activity_type: activity_data['activityType'],
            confidence: activity_data['confidence'],
            start_location: start_location,
            end_location: end_location,
          )
        end
      end
    end
  end

  def timestamp_to_datetime(timestamp)
    require 'date'
    DateTime.strptime(timestamp, '%Y-%m-%dT%H:%M:%S')
  end

  def read_zip_file(file_path)
    output = []
    Zip::File.open(file_path) do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        if entry.file? && !(entry.name =~ /\.DS_Store|__MACOSX|(^|\/)\._/) && entry.name.include?("Semantic Location History")
          puts "#{entry.name} is a semantic position file!"
          data = JSON.parse(entry.get_input_stream.read)
          output << { filename: entry.name, data: data }
        else
          puts "#{entry.name} is not a semantic file !"
        end
      end
    end
    output
  end

  def unzip_file(file_path)
    Zip::File.open(file_path) do |zip_file|
      zip_file.each do |f|
        unless f.name =~ /\.DS_Store|__MACOSX|(^|\/)\._/
          FileUtils.mkdir_p(File.dirname(f.name))
          zip_file.extract(f, f.name) unless File.exist?(f.name)
        end
      end
    end
  end
end
