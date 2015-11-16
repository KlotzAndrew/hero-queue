class SummonerTeam < ActiveRecord::Base
	belongs_to :summoner
	belongs_to :team, touch: true
	belongs_to :tournament

	scope :present, -> {where.not(absent: true)}
	scope :absent, -> {where(absent: true)}

	scope :solos, -> {where(duo_approved: false)}

	attr_accessor :summonerName

	def self.duos
		duo_hash = where(duo_approved: true).includes(:summoner).each_with_object({}) do |t,h|
			if h.has_key?(t.duo_id)
				h[t.duo_id] << t
			else
				h[t.summoner_id] ||= [t]
			end
		end
		duo_hash.values.map {|x,y| [x.summoner, y.summoner]}
	end

	def self.add_to_team_as_ringer(summonerName, tournament_id, team_id)
		summoner = Summoner.find_or_create(summonerName)
		if summoner.id 
			fetcher = Fetcher::Lolkingelo.new([summoner])
			fetcher.update_summoners_elo
			SummonerTeam.transaction do
				summoner.tickets.create!(
					tournament_id: tournament_id,
					status: "Ringer")
				add_summoners_to_tournament(tournament_id, summoner.id, nil, team_id)
			end
		end
	end

	def self.add_summoners_to_tournament(tournament_id, summoner_id, duo_id, team_id = nil)
		if duo_id
				participation_with_duo(tournament_id, summoner_id, duo_id)
		else
			participation_solo(tournament_id, summoner_id, team_id)
		end
	end
	
	private

		def self.participation_solo(tournament_id, summoner_id, team_id = nil)
			SummonerTeam.create(
				tournament_id: tournament_id,
				summoner_id: summoner_id,
				team_id: team_id)
		end

		def self.participation_with_duo(tournament_id, summoner_id, duo_id)
			SummonerTeam.create(
				tournament_id: tournament_id,
				summoner_id: summoner_id,
				duo_id: duo_id,
				duo_approved: true)
			SummonerTeam.create(
				tournament_id: tournament_id,
				summoner_id: duo_id,
				duo_id: summoner_id,
				duo_approved: true)
		end
end