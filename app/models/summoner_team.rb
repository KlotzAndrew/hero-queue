class SummonerTeam < ActiveRecord::Base
	belongs_to :summoner
	belongs_to :team

	scope :present, -> {where.not(absent: true)}
	scope :absent, -> {where(absent: true)}

	attr_accessor :summonerName

	def add_to_team_as_ringer(summonerName, tournament_id, team_id)
		summoner = Summoner.find_or_create(summonerName)
		if summoner.id 
			fetcher = Fetcher::Lolkingelo.new([summoner])
			fetcher.update_summoners_elo
			SummonerTeam.transaction do
				summoner.tickets.create!(
					tournament_id: tournament_id,
					status: "Ringer")
				Team.find(team_id).summoners << summoner
			end
		end
	end

	private
end