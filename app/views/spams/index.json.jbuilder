json.array!(@spams) do |spam|
  json.extract! spam, :id, :patternID, :senderID, :messageID
  json.url spam_url(spam, format: :json)
end
