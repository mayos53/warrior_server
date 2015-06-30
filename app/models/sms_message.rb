class SmsMessage < ActiveRecord::Base
	belongs_to :user ,:foreign_key => "user_id"
	belongs_to :sender ,:foreign_key => "sender_id"
	belongs_to :message_status ,:foreign_key => "message_status_id"
end
