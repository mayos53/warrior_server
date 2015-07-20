json.array!(@suspicious_keywords) do |suspicious_keyword|
  json.extract! suspicious_keyword, :id, :keyword
  json.url suspicious_keyword_url(suspicious_keyword, format: :json)
end
