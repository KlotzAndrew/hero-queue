class Summoner < ActiveRecord::Base
	has_many :tickets, -> {paid}
	has_many :tournament_participations
	has_many :teams, :through => :tournament_participations

	has_many :tournament_participations
	has_many :tournaments, :through => :tournament_participations
	
	def self.find_or_create(summonerName, is_duo = "summoner name", max_throttle = 9)
		summoner_ref = summonerName.mb_chars.downcase.gsub(' ', '').to_s
		existing_summoner = Summoner.where("summoner_ref = ?", summoner_ref).first
		if existing_summoner
			return existing_summoner
		else
			if Fetcher::LolApi.check_throttle(max_throttle)
				Fetcher::LolApi.create_summoner_record(Summoner.new, summoner_ref, summonerName, is_duo)
			else
				Fetcher::LolApi.throttle_limit_error(Summoner.new)
			end
		end
	end 
end
