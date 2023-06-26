require 'zip'
require 'json'

class UploadFileController < ApplicationController

  # def attach_file_to_user
  #   takeout_file = params[:takeout_file].tempfile
  #   puts "____THIS IS THE TAKEOUT FILE_____"
  #   puts takeout_file
  #   unzip_file(takeout_file)
  #   puts takeout_folder = File.dirname(takeout_file)
  #   puts Dir.entries(takeout_folder)
  #   # current_user.takeout_file.attach(params[:takeout_file])
  # end

  #   # redirect_to '/graph'
  # end
  
  private

  def read_zip_file(file_path)
    Zip::File.open(file_path) do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        if entry.directory?
          puts "#{entry.name} is a folder!"
        elsif entry.symlink?
          puts "#{entry.name} is a symlink!"
        elsif entry.file?
          puts "#{entry.name} is a regular file!"

          # Read into memory
          # data = JSON.load(entry.get_input_stream)
          # p entry
          data = JSON.load(entry.get_input_stream)
          return data
        else
          puts "#{entry.name} is something unknown, oops!"
        end
      end
    end
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
