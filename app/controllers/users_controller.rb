class UsersController < ApplicationController

  respond_to :html, :xml, :json	

  def create
    
     phone = get_phone_number(user_params[:phoneNum],user_params[:countryCode])
     @user = User.where(:phoneNum => phone).first
     if @user == nil
        @user = User.new(:phoneNum => phone)
        @user.save
     end   

     respond_to do |format|
        format.html { redirect_to @user}
        format.json { render :json => {:userID => @user.id, :statusCode => RESPONSE_OK}}
     end   
  end

  def register
    user = User.where(:ID => register_params[:userID]).first
    user.regID = register_params[:regID]
    user.save
    
    render :json => {
                      :statusCode => RESPONSE_STATUS_OK
                    }
  end  







  def user_params
    params.permit(:countryCode, :phoneNum)
  end

  def register_params
    params.permit(:userID,:regID)
  end

  end
