json.array!(@series_participations) do |series_participation|
  json.extract! series_participation, :id
  json.url series_participation_url(series_participation, format: :json)
end
