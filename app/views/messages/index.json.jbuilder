json.array!(@messages) do |message|
  json.extract! message, :id, :userId, :phoneNum, :time, :content, :processCode
  json.url message_url(message, format: :json)
end
