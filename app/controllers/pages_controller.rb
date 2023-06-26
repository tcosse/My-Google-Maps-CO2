class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: :home

  def home
  end

  def graph
    takeout_file = current_user.takeout_file
    Zip::File.open('foo.zip') do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        puts "Extracting #{entry.name}"

        # Extract to file or directory based on name in the archive
        entry.extract

        # Read into memory
        content = entry.get_input_stream.read
      end
    end
  end
end
