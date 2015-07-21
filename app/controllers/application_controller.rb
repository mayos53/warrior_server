class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Response constants
  RESPONSE_STATUS_OK    = 1
  RESPONSE_STATUS_ERROR = -1

  RESPONSE_STATUS_INCORRECT_CODE = -200


  skip_before_action :verify_authenticity_token

  	
  protected
  def authenticate_user!
    if !admin_signed_in?
      redirect_to new_admin_session_path, :notice => 'if you want to add a notice'
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end

  def index
  end


end
