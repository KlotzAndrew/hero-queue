class Summoner < ActiveRecord::Base
	has_many :tickets
	has_many :duo_partners, :class_name => "Ticket", :foreign_key => "duo_id"
	has_many :summoner_teams
	has_many :teams, :through => :summoner_teams
	

	cattr_accessor :throttle_league do
	    []
 	end


	def self.read_throttle
		Rails.logger.info "throttle_league: #{@@throttle_league}"
		@@throttle_league
	end

	def find_or_create
		Rails.logger.info "throttle_league: #{@@throttle_league}"
		@@throttle_league << Time.now.to_i
		Rails.logger.info "throttle_league: #{@@throttle_league}"
		summoner_ref = self.summonerName.mb_chars.downcase.gsub(' ', '').to_s
		existing_summoner = Summoner.where("summoner_ref = ?", summoner_ref).first
		if existing_summoner
			return existing_summoner
		else
			create_summoner(summoner_ref, self.summonerName)
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
end
