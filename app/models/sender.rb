class Sender < ActiveRecord::Base
	belongs_to  :sender_type, :foreign_key => "sender_type_id"
	has_many :sms_messages
	has_many :message_patterns
end
