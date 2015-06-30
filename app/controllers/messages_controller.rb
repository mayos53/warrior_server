class MessagesController < ApplicationController
  

  

  NOTIFICATION_TYPE_SYNCHRONIZE = 1

  
  PATTERN_TYPE_IGNORE = 1
  PATTERN_TYPE_SPAM = 2
  PATTERN_TYPE_USER_SELECTED = 3
  PATTERN_TYPE_ELECTION = 4


  SENDER_TYPE_SMS   = 2
  SENDER_TYPE_EMAIL = 3
  SENDER_TYPE_VOICECALL   = 4

  MESSAGE_STATUS_SUSPICIOUS = 1
  MESSAGE_STATUS_SPAM = 2
  MESSAGE_STATUS_IGNORE = 3
  MESSAGE_STATUS_USER_SELECTED = 4
  MESSAGE_STATUS_ELECTION = 5

 
#



  respond_to :html, :xml, :json	

  


  def syncBlackList
    keywords = SuspiciousKeyword.all
    senders  = Sender.all
    
    user_patterns = MessagePattern.includes(:user_patterns)
                                  .where("pattern_type_id = ? and user_patterns.user_id = ?",
                                   PATTERN_TYPE_USER_SELECTED,syncLists_params[:userID])
    other_patterns = MessagePattern.where("pattern_type_id = ? or pattern_type_id = ?",PATTERN_TYPE_SPAM, PATTERN_TYPE_IGNORE)    
    all_patterns = user_patterns + other_patterns

    logger.info "** all_patterns *** #{all_patterns.inspect}**"

    patterns = []
    all_patterns.each do |p|
      if p.pattern_type_id == PATTERN_TYPE_USER_SELECTED 
        patterns << { sender: p.sender_id, text: p.pattern_text, type: p.pattern_type_id, choice: p.user_patterns[0].is_spam}  
      else
        patterns << { sender: p.sender_id, text: p.pattern_text, type: p.pattern_type_id} 
      end
    end  
    
    logger.info "** patterns *** #{patterns.inspect}**"
                               
    words = keywords.map { |e|  e.keyword}
    sender_nums= senders.map { |e|  { from: e.sender_from, type:e.sender_type}}

    render :json => { :status_code => RESPONSE_STATUS_OK,
     :keywords => words,
     :senders => sender_nums,
     :patterns => patterns
    }

  end


  def syncMessages
    messages = SMSMessage.where(:user_id => syncMessages_params[:user_id]) 
    render :json => { :status_code => RESPONSE_STATUS_OK,
                      :messages => messages
                    }
  end

  def reportSpams
    messages = reportSpam_params[:messages]
    user_id = reportSpam_params[:user_id]
    user = User.find(user_id)
    result = []

    messages.each do |message|
      smsMessage = SmsMessage.new()
      smsMessage.user = user
      smsMessage.message_status = MessageStatus.find(message[:message_status_id])
      smsMessage.body_text = message[:body_text]
      if message.message_status_id == MESSAGE_STATUS_SUSPICIOUS
        sender = addSender(message[:phone_num],false)
        smsMessage.sender = sender
      elsif message.message_status_id == MESSAGE_STATUS_SPAM
        sender = addSender(message[:phone_num],true)
        smsMessage.sender = sender
        addPattern(sender, message[:body_text], PATTERN_TYPE_SPAM)
      end       
      result << smsMessage
      smsMessage.save  
    end
    user.last_report_time = reportSpam_params[:report_time]
    user.save

    logger.info "** result[]  *** #{result.inspect}**"
    render :json => { :status_code => RESPONSE_STATUS_OK,
      :messages => result }
    end

  def setSpams
    logger.info "** request set Spams *** #{setSpams_params.inspect}**"
    spams = setSpams_params[:spams]
    spams.each do |spam|
      patternType = spam[:pattern_type]
      pattern = spam[:pattern]
      smsMessage = SMSMessage.includes(:sender).find(spam[:id])

      isInBlackList = false
      case patternType
      when PATTERN_TYPE_SPAM
        smsMessage.message_status = MESSAGE_STATUS_SPAM
        isInBlackList = true
      when PATTERN_TYPE_IGNORE
        smsMessage.message_status = MESSAGE_STATUS_IGNORE
      when PATTERN_TYPE_USER_SELECTED
        smsMessage.message_status = MESSAGE_STATUS_USER_SELECTED
      when PATTERN_TYPE_ELECTION
        smsMessage.message_status = MESSAGE_STATUS_ELECTION
      end
      smsMessage.sender.is_sender_black_list = isInBlackList
      smsMessage.save
      addPattern(smsMessage.sender, pattern, patternType)   
      logger.info "** set spam process code *** #{message.inspect}**"
      message.save

    end
    result = sendNotification(NOTIFICATION_TYPE_SYNCHRONIZE)
    if result == true
      responseStatus = RESPONSE_STATUS_OK
    else
      responseStatus = RESPONSE_STATUS_ERROR
    end
    render :js => "window.location = '/messages'"

 end  

 def addKeyword
    word = addKeyword_params[:keyword]
    keyword = SuspiciousKeyword.new(:word => word)
    keyword.save
    
    respond_to do |format|
        format.html
        format.json {  render :json => {:status => RESPONSE_STATUS_OK } } 
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
      request["Authorization"] = "key=AIzaSyDaKmTRNEqrFlexIIrFzmpFGJ71B4wYDoY"
      request["Content-Type"] = "application/json"
      response = http.request(request)
      logger.info "**********#{response.body.inspect}*****"
      response_parsed = JSON.parse(response.body)
      return response_parsed["failure"] > 0
  end  

  def addPattern(messageSender, messagePattern, patternType)
    messagePatterns = MessagePattern.where(:sender => sender)
    messagePatterns = messagePatterns.sort_by{|x| x.pattern_text.length}
    
    messagePatterns.each do |pattern|
      if pattern == messagePattern    
        foundPattern = messagePattern
        if messagePattern.pattern_type_id == PATTERN_TYPE_SPAM
          pattern.pattern_type_id = PATTERN_TYPE_SPAM
          pattern.save
        end
        break
      end
    end

    if foundPattern == nil
      messagePattern = MessagePattern.new(:sender => sender, :pattern_text => messagePattern, :pattern_type_id => patternType)
      messagePattern.save
    end
  end

  def addSender(phoneNum, isBlackList)
    sender = Sender.find(:phone_num => phoneNum)
    if sender == nil
      sender = Sender.new(:phone_num => phoneNum)
    end
    sender.is_sender_black_list = isBlackList
    sender.save
    return sender
  end


  def syncLists_params
    params.permit(:user_id)
  end

  def reportSpam_params
    params.permit(:report_time, :user_id, messages: [:user_id, :phone_num, :message_status_id, :body_text, :received_time])
  end

  def syncMessages_params
    params.permit(:user_id)
  end

  def setSpams_params
    params.permit(spams: [:id, :pattern, :pattern_type])
  end

  def addKeyword_params
    params.permit(:keyword)
  end
 

end
