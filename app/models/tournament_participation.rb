class TournamentParticipation < ActiveRecord::Base
	belongs_to :summoner
	belongs_to :tournament

	scope :solos, -> {where(duo_approved: false)}
	# scope :duos, -> {where(duo_approved: true)}

	def self.duos
		duo_hash = where(duo_approved: true).each_with_object({}) do |t,h|
			if h.has_key?(t.duo_id)
				h[t.duo_id] << t
			else
				h[t.summoner_id] ||= [t]
			end
		end
		duo_hash.values.map {|x,y| [x.summoner, y.summoner]}
	end

	def self.add_summoners_to_tournament(tournament_id, summoner_id, duo_id)
		if duo_id
				participation_with_duo(tournament_id, summoner_id, duo_id)
		else
			participation_solo(tournament_id, summoner_id)
		end
	end

	def self.participation_solo(tournament_id, summoner_id)
		TournamentParticipation.create(
			tournament_id: tournament_id,
			summoner_id: summoner_id)
	end

	def self.participation_with_duo(tournament_id, summoner_id, duo_id)
		TournamentParticipation.create(
			tournament_id: tournament_id,
			summoner_id: summoner_id,
			duo_id: duo_id,
			duo_approved: true)
		TournamentParticipation.create(
			tournament_id: tournament_id,
			summoner_id: duo_id,
			duo_id: summoner_id,
			duo_approved: true)
	end
end