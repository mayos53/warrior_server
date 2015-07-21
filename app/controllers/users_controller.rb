class UsersController < ApplicationController

  respond_to :json	

  def create
    
     phone = get_phone_number(user_params[:phone_num],user_params[:country_code])
     @user = User.where(:phone_num => phone).first
     if @user == nil
        @user = User.new(:phone_num => phone,:udid => user_params[:udid])
     end   
     code = random_number
     @user.confirmation_code = code
     @user.save

     text = "Your code is : "+code.to_s
     
     # sendSMS(text,phone)

     render :json => {:user => {:user_id => @user.id, :last_report_time => @user.last_report_time}, :status_code => RESPONSE_STATUS_OK}
        
  end


  def confirmCode
   user = User.find(confirm_code_params[:user_id])
   if user.confirmation_code.to_s == confirm_code_params[:confirm_code]
    render :json => { :status_code => RESPONSE_STATUS_OK}
   else
    render :json => { :status_code => RESPONSE_STATUS_INCORRECT_CODE}
   end
  end

  def register
    user = User.find(register_params[:user_id])
    user.reg_id = register_params[:reg_id]
    user.save
    
    render :json => {
                      :status_code => RESPONSE_STATUS_OK
                    }
  end  




  def sendSMS (text,to)
    api_key = "641fd5e0"
    api_secret = "786f96a6"
    from = "Vigilante"
    text = URI::encode(text)
    url="https://rest.nexmo.com/sms/json?api_key="+api_key+"&api_secret="+api_secret+"&from="+from+"&to="+to.to_s+"&text="+text

    logger.info "SMS url "+url

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response_parsed = JSON.parse(response.body)

    if response_parsed["messages"][0]["status"] =="0"
      logger.info "SMS sent"
    else
      logger.info "SMS not sent"
    end  
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



  def confirm_code_params
    params.permit(:user_id,:confirm_code)
  end
  def user_params
    params.permit(:country_code, :phone_num, :udid)
  end

  def register_params
    params.permit(:user_id,:reg_id)
  end

  end
