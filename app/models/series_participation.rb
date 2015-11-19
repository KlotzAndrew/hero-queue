class SeriesParticipation < ActiveRecord::Base
	belongs_to :series
	belongs_to :summoner

	validates :series_id, presence: true
	validates :summoner_id, presence: true

	def self.create_participaton(series, summoner_id)
		SeriesParticipation.create(
			series_id: series.id,
			summoner_id: summoner_id)
	end
end
