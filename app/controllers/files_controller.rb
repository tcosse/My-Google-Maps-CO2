require 'zip'
require 'json'
require 'pp'
require 'benchmark'
require_relative '../sidekiq/populate_db_job'
require 'json'

class FilesController < ApplicationController

  def process_takeout
    takeout_file = params[:takeout_file].tempfile
    puts 'uploadfile', Benchmark.measure {
      # Upload the file to google cloud using active storage
      # current_user.takeout_file.attach(params[:takeout_file])
    }
    puts 'Parsing and inserting data to db', Benchmark.measure {
      # Read Zip Data and populate DataBase using Jsons
      compiled_data = read_zip_file(takeout_file)
      insert_into_db(compiled_data)
      # pp total_distance_per_transport(compiled_data)
    }
  end

  private

  def insert_into_db(compiled_data)
    # pp compiled_data.first
    compiled_data.each do |monthly_data|
      puts "Adding Json data of month #{monthly_data['filename']} to DB"
      PopulateDbJob.perform_async(monthly_data)
    end
  end

  def read_zip_file(file_path)
    output = []
    Zip::File.open(file_path) do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        if entry.file? && !(entry.name =~ /\.DS_Store|__MACOSX|(^|\/)\._/) && entry.name.include?("Semantic Location History")
          puts "#{entry.name} is a semantic position file!"
          data = JSON.parse(entry.get_input_stream.read)
          output << { 'filename' => entry.name, 'data' => data }
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

def strong_params
  params.require(:takeout_file).permit(:tempfile)
end

def total_distance_per_transport(compiled_data)
  total_distance = {}
  compiled_data.each do |monthly_data|
    monthly_data[:data]['timelineObjects'].each do |activity_data|
      #Get only activity segments, as the data also contains 'placeVisit objects' which we don't need
      if activity_data.include?('activitySegment')
        activity_segment = activity_data['activitySegment']
        activity_type = activity_segment['activityType']
        distance = activity_segment['distance'].to_i
        if total_distance.has_key?(activity_type)
          total_distance[activity_type] = distance + total_distance[activity_type]
        else
          total_distance[activity_type] = distance
        end
      end
    end
  end
  return total_distance
end
