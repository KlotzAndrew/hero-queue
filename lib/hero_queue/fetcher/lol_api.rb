module Fetcher
	class LolApi
		cattr_accessor :throttle_league do
		    []
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

	 	def self.throttle_limit_error(summoner)
			summoner.errors.add(:league_servers, "did not respond, try again in a few seconds")
			return summoner
		end

		def self.create_summoner_record(summoner, summoner_ref, name, is_duo)
			url = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/#{summoner_ref}?api_key=" + Rails.application.secrets.league_api_key
			begin
				data = league_api_call(summoner_ref, url)
				summoner.update(
					summonerId: data["id"],
					summonerName: name,
					summoner_ref: summoner_ref,
					summonerLevel: data["summonerLevel"],
					profileIconId: data["profileIconId"])
			rescue Timeout::Error
				summoner.errors.add(:timeout, "the league servers are not responding! Try again in a few minutes")
			rescue OpenURI::HTTPError => ex
				code = ex.message.scan(/\d/).join('')
				if code == "404"
					summoner.errors.add(:cant_find, "your #{is_duo}! Double check the spelling")
				elsif code == "400"
					summoner.errors.add(:invalid_name, "double check the spelling and try again")
				else 
					summoner.errors.add(:no_response, "the league servers are not responding! Try again in a few minutes")
					Rails.logger.info "league_API_error HTTPError: #{ex}"
				end
			rescue => e
				summoner.errors.add(:unknown_error, "happened! Refresh the page and try again in a few minutes")
				Rails.logger.info "league_API_error unknown: #{e}"
			end
			return summoner
		end

		private

		def self.adjust_throttle(time_span = 10)
			if !!@@throttle_league.first && @@throttle_league.first < (Time.now.to_i - time_span)
				@@throttle_league = @@throttle_league.drop(1)
			end
			if !!@@throttle_league.first
				Rails.logger.info "throttle_clear in: #{@@throttle_league.first - (Time.now.to_i - 10)}"
			end
		end	

		def self.league_api_call(summoner_ref, url)
			raw_data = open(URI.encode(url),{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,:read_timeout=>3}).read
			json_hash_ = JSON.parse(raw_data)
			data = json_hash_["#{summoner_ref}"]
			return data
		end
	end
end