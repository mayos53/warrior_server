class MessagesController < ApplicationController
  

  before_filter :authenticate_user!, :only=>[:index,:setSpams]

  NOTIFICATION_TYPE_SYNCHRONIZE = 1

  
  # PATTERN_TYPE_IGNORE = 1
  # PATTERN_TYPE_SPAM = 2
  # PATTERN_TYPE_USER_SELECTED = 3
  # PATTERN_TYPE_ELECTION = 4


  # SENDER_TYPE_SMS   = 2
  # SENDER_TYPE_EMAIL = 3
  # SENDER_TYPE_VOICECALL   = 4

  # MESSAGE_STATUS_SUSPICIOUS = 1
  # MESSAGE_STATUS_SPAM = 2
  # MESSAGE_STATUS_IGNORE = 3
  # MESSAGE_STATUS_USER_SELECTED = 4
  # MESSAGE_STATUS_ELECTION = 5 


  respond_to :html, :xml, :json 

  


  def syncBlackList
    keywords = SuspiciousKeyword.all
    senders  = Sender.all
    message_patterns = MessagePattern.all   

    user_patterns = UserPattern.where({:user_id => syncLists_params[:user_id]})                           
    words = keywords.map { |e|  e.keyword}

    render :json => { :status_code => RESPONSE_STATUS_OK,
     :keywords => words,
     :user_patterns => user_patterns,
     :senders => senders,
     :patterns => message_patterns
     
    }

  end


  def syncMessages
   logger.info "** syncMessages_params *** #{syncMessages_params.inspect}**"

    user_id = syncMessages_params[:user_id]
    message_ids = syncMessages_params[:messages_ids]
    statuses = syncMessages_params[:statuses]
    user_patterns_id = syncMessages_params[:user_patterns_id]
    user_selections_value = syncMessages_params[:user_selections_value]
    
    if user_patterns_id != nil
      user_patterns_id.zip(user_selections_value).each do |user_pattern_id,user_selection|
        if UserPattern.where({:user_id =>user_id ,:message_pattern_id => user_pattern_id}).exists?
          UserPattern.where({:user_id =>user_id ,:message_pattern_id => user_pattern_id}).first.update_columns({:is_spam => user_selection})
        else
          UserPattern.new({:user_id =>user_id ,:message_pattern_id => user_pattern_id,:is_spam => user_selection}).save
        end
      end
    end
    if message_ids != nil
      message_ids.zip(statuses).each do |message_id,status|
        SmsMessage.find(message_id).update_columns(:message_status_id => status)
      end
    end
    
    message_patterns = MessagePattern.all   
    senders  = Sender.all
    keywords = SuspiciousKeyword.all
    messages = SmsMessage.where(:user_id => user_id).select("id","message_status_id")

    message_ids = []
    statuses = []
    messages.each do |message|
      message_ids << message.id
      statuses << message.message_status_id
    end

    words = keywords.map { |e|  e.keyword}

    render :json => { :status_code => RESPONSE_STATUS_OK,
     :keywords => words,
     :senders => senders,
     :patterns => message_patterns,
     :message_ids => message_ids,
     :statuses => statuses
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
      smsMessage.message_status_id = message[:message_status_id]
      smsMessage.body_text = message[:body_text]
      smsMessage.received_time =  message[:received_time] 
      if message[:message_status_id] == MESSAGE_STATUS_SUSPICIOUS
        sender = addSender(message[:phone_num],false)
        smsMessage.sender = sender
      else 
        if message[:message_status_id] == MESSAGE_STATUS_USER_SELECTED
           pattern = getPattern(message[:sender_id],message[:body_text])
           if pattern != nil
              user_pattern = UserPattern.where({:user_id => user_id, :message_pattern_id => pattern.id})
              if user_pattern.exists?
                 if user_pattern.first.is_spam?
                    smsMessage.message_status_id = MESSAGE_STATUS_USER_SELECTED_SPAM
                  else
                    smsMessage.message_status_id = MESSAGE_STATUS_USER_SELECTED_IGNORE
                  end
              end
           end
        end
        smsMessage.sender_id = message[:sender_id]
      end       
      smsMessage.save  
      result << smsMessage.to_h.merge({:reported_id => message[:id]})
    end


    user.last_report_time = reportSpam_params[:report_time]
    user.save

    #TODO:return only ids and statuses 

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
      sender_id = SmsMessage.find(spam[:id]).sender_id
      #TODO: set black list to true for spams and user spams
      messagePattern = addPattern(sender_id, pattern, patternType)   
      setMessageStatus(messagePattern)
    end

    result = sendNotification(NOTIFICATION_TYPE_SYNCHRONIZE)
    if result == true
      responseStatus = RESPONSE_STATUS_OK
    else
      responseStatus = RESPONSE_STATUS_ERROR
    end


    render :js => "window.location = '/messages'"

 end  

 def setMessageStatus(messagePattern)
    messages = SmsMessage.where(:sender_id => messagePattern.sender_id)
    logger.info "** MESSAGES COUNT  #{messages.count}**"
    messages.each { |message| 
      logger.info "********** compare #{message.body_text} and #{messagePattern.pattern_text} *****"
      if message.body_text.include? messagePattern.pattern_text
        logger.info "********** include *****"
        logger.info "********** patternType : #{}{messagePattern.pattern_type_id} *****"
        case messagePattern.pattern_type_id
          when PATTERN_TYPE_SPAM
            logger.info "** set PATTERN type SPAM  #{message.sender_id}**"
            message.message_status_id = MESSAGE_STATUS_SPAM
          when PATTERN_TYPE_IGNORE
            message.message_status_id = MESSAGE_STATUS_IGNORE
          when PATTERN_TYPE_USER_SELECTED
            message.message_status_id = MESSAGE_STATUS_USER_SELECTED
          when PATTERN_TYPE_ELECTION
            message.message_status_id = MESSAGE_STATUS_ELECTION
        end
        message.save
      end
    }
 end


  

  ################ Private methods ##############################



  def sendNotification(notificationType)
    uri = URI.parse("https://android.googleapis.com/gcm/send")
    http = Net::HTTP.new(uri.host)
    request = Net::HTTP::Post.new(uri.request_uri)

    users = User.all
    regIDs = users.map { |user| user.reg_id }
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

  def addPattern(messageSenderId, messagePattern, patternType)
    messagePatterns = MessagePattern.where(:sender_id => messageSenderId)
    messagePatterns = messagePatterns.sort_by{|x| x.pattern_text.length}
    foundPattern = nil
    messagePatterns.each do |pattern|
      if pattern.pattern_text == messagePattern    
        foundPattern = pattern

        # Override existing pattern only if the new pattern is SPAM
        if patternType == PATTERN_TYPE_SPAM
          pattern.pattern_type_id = PATTERN_TYPE_SPAM
          pattern.save
        end
        break
      end
    end
    if foundPattern == nil
      newPattern = MessagePattern.new(:sender_id => messageSenderId, :pattern_text => messagePattern, :pattern_type_id => patternType)
      newPattern.save
      return newPattern
    else
      return foundPattern
    end
  end

  def getPattern(messageSenderId,messageBody)
    messagePatterns = MessagePattern.where({:sender_id => messageSenderId})
    messagePatterns = messagePatterns.sort_by{|x| x.pattern_text.length}
    messagePatterns.each do |pattern|
      if messageBody.include? pattern.pattern_text
        return pattern
      end
    end
    return nil
  end


  

  def addSender(phoneNum, isBlackList)
    sender = Sender.where(:sender_from => phoneNum).first
    if sender == nil
      sender = Sender.new(:sender_from => phoneNum,:sender_type_id => SENDER_TYPE_SMS)
    end
    sender.is_sender_black_list = isBlackList
    sender.save
    return sender
  end

  def getMessages 
    user_id = getMessages_params[:user_id]
    messages = SmsMessage.where({:user_id =>user_id})
    
    result = []
    messages.each do |message|
      result << message.to_h
    end
    render :json => { :status_code => RESPONSE_STATUS_OK,
      :messages => result }
 end


  def syncLists_params
    params.permit(:user_id);
  end

  def reportSpam_params
    params.permit(:report_time, :user_id, messages: [:id, :user_id, :phone_num, :sender_id, :message_status_id, :body_text, :received_time])
  end

  def syncMessages_params
    params.permit(:user_id,messages_ids:[],statuses:[],user_patterns_id:[],user_selections_value:[])
  end

  def setSpams_params
    params.permit(spams: [:id, :pattern, :pattern_type])
  end

  def addKeyword_params
    params.permit(:keyword)
  end

  def getMessages_params
    params.permit(:user_id)
  end
 

end

