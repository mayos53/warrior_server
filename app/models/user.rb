class User < ActiveRecord::Base
	has_many :sms_messages
end
