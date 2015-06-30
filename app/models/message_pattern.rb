class MessagePattern < ActiveRecord::Base
	belongs_to :sender , :foreign_key => "sender_id"
	belongs_to :pattern_type, :foreign_key => "pattern_type_id" 
	has_many   :user_patterns
end
