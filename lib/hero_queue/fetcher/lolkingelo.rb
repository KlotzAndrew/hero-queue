module Fetcher
	class Lolkingelo
		attr_reader :summoners_array

		def initialize(summoners_array)
			@summoners_array = summoners_array
		end

		def update_summoners_elo
			get_elo
		end

		private

		def get_elo
			without_elo = @summoners_array.select { |x| x unless x.elo }
			base_url = 'http://www.lolking.net/summoner/na/'
			nokogiri_request(without_elo, base_url)
		end

		def nokogiri_request(without_elo, base_url)

			Rails.logger.info "without_elo: #{without_elo.map {|x| x.summonerName}}"
			without_elo.each do |summoner|
				begin
					url = base_url + summoner.summonerId.to_s
					update_summoner_elo(url, summoner)
				rescue => e
					Rails.logger.info "Lolking nokogiri_error: #{e}"
				end
			end
		end

		def update_summoner_elo(url, summoner)
			#fetcher should not be updating objects
			elo = 0
			raw_data = Nokogiri::HTML(open(URI.encode(url),{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,:read_timeout=>3}))
			elo = find_lolking_elo(raw_data).to_i
			Rails.logger.info "summoner/elo: #{summoner.summonerName}/#{elo}"
			summoner.update(elo: elo) if elo_valid?(elo)
		end

		def find_lolking_elo(raw_data)
			raw_data.css('ul.personal_ratings li').each do |rating|
			    if rating.css('div.personal_ratings_heading').text == "Solo 5v5"
			    	return rating.css('div.personal_ratings_lks').text
			    end
			end
		end

		def elo_valid?(elo)
			if elo < 4000 && elo > 0
				return true
			else 
				Rails.logger.info "Lolking nokogiri_error: elo invalid #{elo}"
				return false
			end
		end
	end
end