class Spam < ActiveRecord::Base
	belongs_to :sender, :foreign_key => "senderID"
	belongs_to :pattern, :foreign_key => "patternID"
	belongs_to :message, :foreign_key => "messageID" 
end
