class Summoner < ActiveRecord::Base
	has_many :tickets
	has_many :duo_partners, :class_name => "Ticket", :foreign_key => "duo_id"
	has_many :summoner_teams
	has_many :teams, :through => :summoner_teams
	
	cattr_accessor :throttle_league do
	    []
 	end

	def find_or_create
		summoner_ref = self.summonerName.mb_chars.downcase.gsub(' ', '').to_s
		existing_summoner = Summoner.where("summoner_ref = ?", summoner_ref).first
		if existing_summoner
			return existing_summoner
		else
			if check_throttle(9)
				create_summoner(summoner_ref, self.summonerName)
			end
		end
	end

	def create_summoner(summoner_ref, name)
		url = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/#{summoner_ref}?api_key=" + Rails.application.secrets.league_api_key
		begin
			summoner_data = open(URI.encode(url),{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,:read_timeout=>3}).read
			summoner_hash = JSON.parse(summoner_data)
			Rails.logger.info "summoner_hash: #{summoner_hash}"
			data = summoner_hash["#{summoner_ref}"]
			Rails.logger.info "data: #{data}"
			summoner = Summoner.create(
				summonerId: data["id"],
				summonerName: name,
				summoner_ref: summoner_ref,
				summonerLevel: data["summonerLevel"],
				profileIconId: data["profileIconId"])
			return summoner
		rescue
			return Summoner.new
		end
	end

	def self.check_throttle(throttle_limit)
		Rails.logger.info "@@throttle_league.count: #{@@throttle_league.count}"
		adjust_throttle(10)
		if @@throttle_league.count < throttle_limit
			@@throttle_league << Time.now.to_i
			return true
		else
			return false
		end
	end

	def self.adjust_throttle(time_span)
		if !!@@throttle_league.first && @@throttle_league.first < (Time.now.to_i - time_span)
			@@throttle_league = @@throttle_league.drop(1)
		end
		if !!@@throttle_league.first
			Rails.logger.info "throttle_clear in: #{@@throttle_league.first - (Time.now.to_i - 10)}"
		end
	end
end
