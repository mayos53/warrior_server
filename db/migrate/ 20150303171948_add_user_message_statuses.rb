class AddUserMessageStatuses < ActiveRecord::Migration
	def self.up
		MessageStatus.create([
					 {id: MESSAGE_STATUS_USER_SELECTED_SPAM, internal_name:'User Spam',display_text:'ספאם עבור המשתמש'},
					 {id: MESSAGE_STATUS_USER_SELECTED_IGNORE, internal_name:'User Ignore',display_text:'המשתמש התעלם'}])
	end
	
end