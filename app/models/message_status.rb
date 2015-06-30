class MessageStatus < ActiveRecord::Base
	has_many  :sms_messages
end
