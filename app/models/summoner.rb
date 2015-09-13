class Summoner < ActiveRecord::Base
	has_many :tickets
	has_many :duo_partners, :class_name => "Ticket", :foreign_key => "duo_id"
	has_many :summoner_teams
	has_many :teams, :through => :summoner_teams
	
	cattr_accessor :throttle_league do
	    []
 	end

	def self.find_or_create(summonerName, max_throttle = 9)
		summoner_ref = summonerName.mb_chars.downcase.gsub(' ', '').to_s
		existing_summoner = Summoner.where("summoner_ref = ?", summoner_ref).first
		if existing_summoner
			return existing_summoner
		else
			if check_throttle(max_throttle)
				Summoner.new.create_summoner(summoner_ref, summonerName)
			else
				Summoner.new.throttle_limit
			end
		end
	end

	def throttle_limit
		self.errors.add(:league_servers, "did not respond, try again in a few seconds")
		return self
	end

	def create_summoner(summoner_ref, name)
		url = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/#{summoner_ref}?api_key=" + Rails.application.secrets.league_api_key
		begin
			summoner_data = open(URI.encode(url),{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,:read_timeout=>3}).read
			summoner_hash = JSON.parse(summoner_data)
			Rails.logger.info "summoner_hash: #{summoner_hash}"
			data = summoner_hash["#{summoner_ref}"]
			Rails.logger.info "data: #{data}"
			self.update(
				summonerId: data["id"],
				summonerName: name,
				summoner_ref: summoner_ref,
				summonerLevel: data["summonerLevel"],
				profileIconId: data["profileIconId"])
		# rescue Exception => ex
		# 	code = ex.message.match(/.*?- (\d+): (.*)/)[1]
		# 	case code
		# 	when '404'
		# 		self.errors.add(:cant_find, "your summoner name! Double check the spelling")
		# 	end
		rescue Timeout::Error
			self.errors.add(:timeout, "the league servers are not responding! Try again in a few minutes")
		rescue => e
			self.errors.add(:cant_find, "your summoner name! Double check the spelling")
			Rails.logger.info "league API unknown error: #{e}"
		end
		return self
	end

	def self.check_throttle(max_throttle)
		Rails.logger.info "@@throttle_league.count: #{@@throttle_league.count}"
		adjust_throttle
		if @@throttle_league.count < max_throttle
			@@throttle_league << Time.now.to_i
			return true
		else
			return false
		end
	end

	def self.adjust_throttle(time_span = 10)
		if !!@@throttle_league.first && @@throttle_league.first < (Time.now.to_i - time_span)
			@@throttle_league = @@throttle_league.drop(1)
		end
		if !!@@throttle_league.first
			Rails.logger.info "throttle_clear in: #{@@throttle_league.first - (Time.now.to_i - 10)}"
		end
	end
end
