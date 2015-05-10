class UsersController < ApplicationController

  respond_to :html, :xml, :json	

  def register
    user = User.where(user_params).first
    if user == nil 
      user = User.new(user_params)
    	user.save
    end

    render :json => {
                    :statusCode => STATUS_OK,
                    :userId => user.ID,
                    :phoneNum => user.phoneNum,
                    :UDID => user.UDID
                    }
  end
  	
  def registerForNotifications
    user = User.where(:ID => registerForNotifications_params[:ID]).first
    user.regID = registerForNotifications_params[:regID]
    user.save
    
    render :json => {
                      :statusCode => STATUS_OK
                    }
  end  




def user_params
  params.require(:user).permit(:UDID, :phoneNum)
end

def registerForNotifications_params
  params.require(:user).permit(:ID,:regID)
end

end
