class UsersController < ApplicationController

  respond_to :html, :xml, :json	

  def create
    
     phone = get_phone_number(user_params[:phone_num],user_params[:country_code])
     @user = User.where(:phone_num => phone).first
     if @user == nil
        @user = User.new(:phone_num => phone)
        @user.save
     end   

       render :json => {:user => {:user_id => @user.id, :last_report_time => @user.last_report_time}, :status_code => RESPONSE_STATUS_OK}
        
  end

  def register
    user = User.find(register_params[:user_id])
    user.reg_id = register_params[:reg_id]
    user.save
    
    render :json => {
                      :status_code => RESPONSE_STATUS_OK
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
    params.permit(:country_code, :phone_num)
  end

  def register_params
    params.permit(:user_id,:reg_id)
  end

  end
