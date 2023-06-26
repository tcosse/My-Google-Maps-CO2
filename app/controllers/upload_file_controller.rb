require 'zip'
require 'json'
require 'pp'

class UploadFileController < ApplicationController

  def process_takeout
    # Upload the file to google cloud using active storage
    current_user.takeout_file.attach(params[:takeout_file])

    # Read Zip Data and populate DataBase using Jsons
    takeout_file = params[:takeout_file].tempfile
    compiled_data = read_zip_file(takeout_file)
    # pp data
    insert_into_db(compiled_data)
  end

  private

  def insert_into_db(compiled_data)
    compiled_data.each do |monthly_data|
      puts "Adding Json data of month #{monthly_data[:filename]} to DB"
      monthly_data[:data]['timelineObjects'][0].each do |activities|
        if activities.include?('activitySegment')
          pp activities[1]
          start_location = Location.create!(
            latitude: activities['startLocation']['latitude'],
            longitude: activities['startLocation']['longitude'])
          end_location = Location.create!(
            latitude: activities['endLocation']['latitude'],
            longitude: activities['endLocation']['longitude'])
          # Trip.create!(
          #   start_time: activities['duration']['latitude']
          #   end_time: activities['duration']['latitude']
          # )
      end
    end
  end

  def read_zip_file(file_path)
    output = []
    Zip::File.open(file_path) do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        if entry.directory?
          puts "#{entry.name} is a folder!"
        elsif entry.symlink?
          puts "#{entry.name} is a symlink!"
        elsif entry.file? && !(entry.name =~ /\.DS_Store|__MACOSX|(^|\/)\._/)
          puts "#{entry.name} is a regular file!"
          data = JSON.parse(entry.get_input_stream.read)
          output << { filename: entry.name, data: data }
        else
          puts "#{entry.name} is something unknown, oops!"
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
