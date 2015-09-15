class Summoner < ActiveRecord::Base
	has_many :tickets
	has_many :duo_partners, :class_name => "Ticket", :foreign_key => "duo_id"
	has_many :summoner_teams
	has_many :teams, :through => :summoner_teams
	
	def self.find_or_create(summonerName, is_duo = "summoner name", max_throttle = 9)
		summoner_ref = summonerName.mb_chars.downcase.gsub(' ', '').to_s
		existing_summoner = Summoner.where("summoner_ref = ?", summoner_ref).first
		if existing_summoner
			return existing_summoner
		else
			if LolApi.check_throttle(max_throttle)
				LolApi.create_summoner_record(Summoner.new, summoner_ref, summonerName, is_duo)
			else
				LolApi.throttle_limit_error(Summoner.new)
			end
		end
	end
end
