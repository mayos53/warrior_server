class MessagesController < ApplicationController


  MSG_PROCESS_CODE_SPAM = 2
  MSG_PROCESS_CODE_PERSONAL_SPAM = 3
  MSG_PROCESS_CODE_SUSPECT = 4

  NOTIFICATION_TYPE_SYNCHRONIZE = 1




  respond_to :html, :xml, :json	

  def syncBlackList
    keywords = Keyword.all
    senders  = Sender.all
    words = keywords.map { |e|  e.word}
    sender_nums= senders.map { |e|  e.PhoneNum}

    render :json => { :statusCode => RESPONSE_STATUS_OK,
     :keywords => words,
     :senders => sender_nums }

  end

  def reportSpams
    messages = reportSpam_params[messages]
    @patterns = Pattern.all
    result = []

    messages.each do |message|
      message = Message.new(message)
      if message.processCode == MSG_PROCESS_CODE_SPAM
        pattern = checkPattern(message.content) 
        if pattern != nil
          spam = Spam.new
          spam.message = message
          spam.pattern = pattern

          # assume that sender is already in table
          sender = Sender.where(:phoneNum => message.phoneNum).first
          spam.sender = sender
          spam.save

          if pattern.sure
            message.processCode = MSG_PROCESS_CODE_SPAM
          else
            message.processCode = MSG_PROCESS_CODE_PERSONAL_SPAM  
          end
          result << message
          message.save
        end
      elsif message.processCode == MSG_PROCESS_CODE_SUSPECT
        message.save
      end
    end
    render :json => { :statusCode => RESPONSE_STATUS_OK,
                      :messages => result }
  end

  def setSpams
    spams = setSpams_params[:spams]
    spams.each do |spam|
      message = Message.find(spam.id)
      addPattern(message.content,spam.sure)
      addSenderToBlackList(message.phoneNum)
      message.processCode = MSG_PROCESS_CODE_SPAM
      message.save
    end
    result = sendNotification(NOTIFICATION_TYPE_SYNCHRONIZE)
    if result == true
      responseStatus = RESPONSE_STATUS_OK
    else
      responseStatus = RESPONSE_STATUS_ERROR
    end
    respond_to do |format|
        format.html
        format.json {  render :json => {:status => responseStatus } } 
    end
 end  

  ################ Private methods ##############################



  def sendNotification(notificationType)
    uri = URI.parse("https://android.googleapis.com/gcm/send")
    http = Net::HTTP.new(uri.host)
    request = Net::HTTP::Post.new(uri.request_uri)

    users = User.all
    regIDs = users.map { |user| user.regID }
    request.body= {
        :registration_ids =>  regIDs,
        :data => {
          :type    => notificationType,  
        }
      }.to_json
      request["Authorization"] = "key=AIzaSyDZlgujjp_pKOUftg3UXVTczyvf7ZHPR-Y"
      request["Content-Type"] = "application/json"
      response = http.request(request)
      logger.info "**********#{response.body.inspect}*****"
      response_parsed = JSON.parse(response.body)
      return response_parsed["failure"] > 0
  end  

  
  def checkPattern(content)
    @patterns.each do |pattern|
      if content == pattern.content
        return pattern
      end
    end
    return nil
  end

  def addPattern(content, sure)
    pattern = Pattern.new(:content => content, :sure => sure)
    pattern.save
  end

  def addSenderToBlackList(phoneNum)
    sender = Sender.new(:phoneNum => phoneNum)
    sender.save
  end


  def reportSpam_params
    params.permit(:messages,:userId)
  end

  def setSpams_params
    params.permit(:messagIds)
  end
 

end
