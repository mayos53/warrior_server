class MessagesController < ApplicationController
  

  MSG_PROCESS_CODE_OK = 1
  MSG_PROCESS_CODE_SPAM = 2
  MSG_PROCESS_CODE_CHOICE = 3
  MSG_PROCESS_CODE_SUSPECT = 4

  NOTIFICATION_TYPE_SYNCHRONIZE = 1

  PATTERN_TYPE_SPAM = 3
  PATTERN_TYPE_CHOICE = 2
  PATTERN_TYPE_IGNORE = 1

 



#meir abergel 0525995578 elgrabli

  respond_to :html, :xml, :json	

  


  def syncBlackList
    keywords = Keyword.all
    senders  = Sender.all
    choicePatterns = Pattern.where(patternType: [PATTERN_TYPE_CHOICE,PATTERN_TYPE_IGNORE])

    words = keywords.map { |e|  e.word}
    sender_nums= senders.map { |e|  e.phoneNum}

    render :json => { :statusCode => RESPONSE_STATUS_OK,
     :keywords => words,
     :senders => sender_nums,
     :choicePatterns => choicePatterns
    }

  end


  def syncMessages
    userID = syncMessages_params[:userID]
    messages = Message.includes(:user).where(:userId => userID) 
    render :json => { :statusCode => RESPONSE_STATUS_OK,
                      :messages => messages
   }
  end

  def reportSpams
    messages = reportSpam_params[:messages]
    userID = reportSpam_params[:userID]
    user = User.where(:ID => userID).first
    @patterns = Pattern.all
    result = []

    messages.each do |message|
      message = Message.new(message)
      message.user = user
      if !Message.where(:_ID => message._ID).where(:user => message.user).exists?
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

            if pattern.patternType == PATTERN_TYPE_SPAM
              message.processCode = MSG_PROCESS_CODE_SPAM
              result << message
            elsif pattern.patternType == PATTERN_TYPE_CHOICE
              message.processCode = MSG_PROCESS_CODE_CHOICE  
              result << message    
            end
            message.save
          end
        elsif message.processCode == MSG_PROCESS_CODE_SUSPECT
          result << message
          message.save
        end
      else
        result << message
      end
    end
    
    user.lastReportTime = reportSpam_params[:reportTime]
    user.save

    logger.info "** result[]  *** #{result.inspect}**"
    render :json => { :statusCode => RESPONSE_STATUS_OK,
                      :messages => result }
  end

  def setSpams
    logger.info "** request set Spams *** #{setSpams_params.inspect}**"


    spams = setSpams_params[:spams]
    spams.each do |spam|
      patternType = spam[:patternType]
      pattern = spam[:pattern]
      message = Message.find(spam[:id])
      if pattern != nil  
          addPattern(pattern, patternType)
      end    
      addSenderToBlackList(message.phoneNum)
      logger.info "***** patternType #{patternType}*********"


      if patternType == PATTERN_TYPE_SPAM
        message.processCode = MSG_PROCESS_CODE_SPAM
      elsif patternType == PATTERN_TYPE_CHOICE
        message.processCode = MSG_PROCESS_CODE_CHOICE
      elsif patternType == PATTERN_TYPE_IGNORE
        message.processCode = MSG_PROCESS_CODE_OK
      end  
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
    keyword = Keyword.new(:word => word)
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

  


  def checkPattern(content)
    @patterns.each do |pattern|
      if content == pattern.content
        return pattern
      end
    end
    return nil
  end

  def addPattern(content, patternType)
    pattern = Pattern.where(:content => content).first
    if pattern == nil
       pattern = Pattern.new(:content => content, :patternType => patternType)
    else
       pattern.patternType = patternType
    end
    pattern.save   
  end

  def addSenderToBlackList(phoneNum)
    sender = Sender.where(:phoneNum => phoneNum).first
    if sender == nil
      sender = Sender.new(:phoneNum => phoneNum)
      sender.save
    end
  end


  def reportSpam_params
    params.permit(:reportTime, :userID, messages: [:_ID, :userId, :phoneNum, :time, :content, :processCode])
  end

  def syncMessages_params
    params.permit(:userID)
  end

  def setSpams_params
    params.permit(spams: [:id,:pattern, :patternType])
  end

  def addKeyword_params
    params.permit(:keyword)
  end
 

end
