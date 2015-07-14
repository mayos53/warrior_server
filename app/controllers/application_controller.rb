class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Response constants
  RESPONSE_STATUS_OK    = 1
  RESPONSE_STATUS_ERROR = -1

  RESPONSE_STATUS_INCORRECT_CODE = -200


  skip_before_action :verify_authenticity_token

  	



end
