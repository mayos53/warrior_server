json.array!(@users) do |user|
  json.extract! user, :id, :PhoneNum, :UDID, :RegID
  json.url user_url(user, format: :json)
end
