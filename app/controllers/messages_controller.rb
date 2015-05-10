class MessagesController < ApplicationController

  respond_to :html, :xml, :json	

  def syncBlackList
  	
    keywords = Keyword.all
  	senders  = Sender.all
  	words = keywords.map { |e|  e.word}
  	sender_nums= senders.map { |e|  e.PhoneNum}

  	render :json => {
        						 :statusCode => STATUS_OK,
        						 :keywords => words,
        						 :senders => sender_nums
        						}
    
  	 
  end

  



end
