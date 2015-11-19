class Series < ActiveRecord::Base
	has_many :tournaments
	has_many :series_participations

	validates :name, presence: true

	scope :newest, -> {order(created_at: :asc)}

	def summoners
		series_participations.includes(:summoner).map(&:summoner)
	end

	def self.add_summoners_to_series(tournament, summoner_id, duo_id)
		series = Series.find(tournament.series_id)
		all_participants = series.series_participations.map(&:summoner_id)
		SeriesParticipation.create_participaton(series, summoner_id) unless all_participants.include?(summoner_id)
		if duo_id
			SeriesParticipation.create_participaton(series, duo_id) unless all_participants.include?(duo_id)
		end
	end
end
