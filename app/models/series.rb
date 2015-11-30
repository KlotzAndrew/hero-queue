class Series < ActiveRecord::Base
	has_many :tournaments
	has_many :series_participations

	validates :name, presence: true

	scope :newest, -> {order(created_at: :asc)}

	POINTS = {
		1 => 1000,
		2 => 800,
		3 => 600,
		4 => 500,
		5 => 400,
		6 => 400,
		7 => 200,
		8 => 200
	}

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

	def calculate_stats
		stats = []
		self.series_participations.includes(:tournament_participations, :summoner).each do |sp|
			if sp.tournament_participations.first
				points = POINTS[sp.tournament_participations.first.team.position]
				total = points || 0
				stats << {
					summonerName: sp.summoner.summonerName,
					points: [points],
					total: total
					}
			end
		end
		return stats.sort_by {|k| k[:total]}.reverse

	end
end
