class UsersController < ApplicationController

  respond_to :html, :xml, :json	

  def create
    
     phone = get_phone_number(user_params[:phoneNum],user_params[:countryCode])
     @user = User.where(:phoneNum => phone).first
     if @user == nil
        @user = User.new(:phoneNum => phone)
        @user.save
     end   

       render :json => {:user => {:userID => @user.id, :lastReportTime => @user.lastReportTime}, :statusCode => RESPONSE_STATUS_OK}
        
  end

  def register
    user = User.where(:ID => register_params[:userID]).first
    user.regID = register_params[:regID]
    user.save
    
    render :json => {
                      :statusCode => RESPONSE_STATUS_OK
                    }
  end  


  def random_number
    1_001+ Random.rand(9_999 - 1_001) 
  end 

  # get phone with country_code
   def get_phone_number(phone,countryCode)
     if phone.start_with?("0")
      phone = phone[1..-1]
     end  
     countryCode.to_s+phone
   end   




  def user_params
    params.permit(:countryCode, :phoneNum)
  end

  def register_params
    params.permit(:userID,:regID)
  end

  end
