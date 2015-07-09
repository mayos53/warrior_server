json.array!(@patterns) do |pattern|
  json.extract! pattern, :id, :content
  json.url pattern_url(pattern, format: :json)
end
