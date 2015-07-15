class SmsMessage < ActiveRecord::Base
	belongs_to :user ,:foreign_key => "user_id"
	belongs_to :sender ,:foreign_key => "sender_id"
	belongs_to :message_status ,:foreign_key => "message_status_id"


	def to_h
   	{
   		id: self.id,
   		sender_id: self.sender_id,	
   		message_status_id: self.message_status_id,
   		user_id: self.user_id,
   		body_text: self.body_text,
   		received_time: self.received_time

   	}			
   end	
end
