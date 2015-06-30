class UserPattern < ActiveRecord::Base
	belongs_to :message_pattern, :foreign_key => "message_pattern_id" 
end
