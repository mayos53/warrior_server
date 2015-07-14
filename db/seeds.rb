# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


PatternType.delete_all
SenderType.delete_all
MessageStatus.delete_all


PatternType.create([{id: PATTERN_TYPE_IGNORE, internal_name:'Ignore',display_text:'התעלם'},
					{id: PATTERN_TYPE_SPAM, internal_name:'Spam',display_text:'ספאם'},
					{id: PATTERN_TYPE_USER_SELECTED, internal_name:'User_Selected',display_text:'בחירת משתמש'},
					{id: PATTERN_TYPE_ELECTION, internal_name:'Election',display_text:'בחירות'}
					])

SenderType.create([{ id: SENDER_TYPE_SMS, internal_name:'SMS',display_text:'הודעות SMS'},
					 { id: SENDER_TYPE_EMAIL, internal_name:'Email',display_text:'מייל'},
					 { id: SENDER_TYPE_VOICECALL, internal_name:'Voice Call',display_text:'טלפון'}])					 



MessageStatus.create([{ id: MESSAGE_STATUS_SUSPICIOUS, internal_name:'Suspicious',display_text:'חשוד'},
					 {id: MESSAGE_STATUS_SPAM, internal_name:'Spam',display_text:'ספאם'},
					 {id: MESSAGE_STATUS_IGNORE, internal_name:'Ignore',display_text:'התעלם'},
					 {id: MESSAGE_STATUS_USER_SELECTED, internal_name:'User Selected',display_text:'בחירת משתמש'},
					 {id: MESSAGE_STATUS_ELECTION, internal_name:'Election',display_text:'בחירות'},
					 {id: MESSAGE_STATUS_USER_SELECTED_SPAM, internal_name:'User Spam',display_text:'ספאם עבור המשתמש'},
					 {id: MESSAGE_STATUS_USER_SELECTED_IGNORE, internal_name:'User Ignore',display_text:'המשתמש התעלם'}])
