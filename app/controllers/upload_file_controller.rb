class UploadFileController < ApplicationController

  def attach_file_to_user
    current_user.takeout_file.attach(params[:takeout_file])
    redirect_to '/graph'
  end
end
