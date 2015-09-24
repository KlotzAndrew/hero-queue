class Tournament < ActiveRecord::Base
	has_many :tickets
	has_many :teams

	def all_solos
		tickets.includes(:summoner).where(duo_id: nil).map {|x| x.summoner}
	end

	def all_duos
		tickets.includes(:summoner, :duo).where.not(duo_id: nil).map {|x| [x.summoner, x.duo]}
	end

	def nokogiri_elo
		all_sums = self.all_solos + self.all_duos.flatten
		without_elo = all_sums.select { |x| x unless x.elo }
		base_url = 'http://www.lolking.net/summoner/na/'
		nokogiri_request(without_elo, base_url)
	end

	def nokogiri_request(without_elo, base_url)
		without_elo.each do |x|
			begin
				elo = 0
				url = base_url + x.summonerId.to_s
				raw_data = Nokogiri::HTML(open(URI.encode(url),{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,:read_timeout=>3}))
				elo = find_lolking_elo(raw_data).to_i

				Rails.logger.info "summoner/elo: #{x.summonerName}/#{elo}"
				x.update(elo: elo) if elo_valid?(elo)
			rescue => e
				Rails.logger.info "Lolking nokogiri_error: #{e}"
			end
		end
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

	def self.legacy
		array = []
		array << Tournament.new(
			start_date: 1.year.ago,
			name: "Solo/Duo Queue Tournament 6",
			start_date: Time.at(1417255200),
			facebook_url: "https://www.facebook.com/events/799418926785166")
		array << Tournament.new(
			start_date: 1.year.ago,
			name: "Solo/Duo Queue Tournament 5",
			start_date: Time.at(1413626400),
			facebook_url: "https://www.facebook.com/events/944769515538563")
		array << Tournament.new(
			start_date: 1.year.ago,
			name: "Solo/Duo Queue Tournament 4",
			start_date: Time.at(1411207200),
			facebook_url: "https://www.facebook.com/events/418839091590865")
		array << Tournament.new(
			start_date: 1.year.ago,
			name: "Solo/Duo Queue Tournament 3",
			start_date: Time.at(1407578400),
			facebook_url: "https://www.facebook.com/events/836624339681535")
		return array
	end	
end
