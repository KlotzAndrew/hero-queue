class Tournament < ActiveRecord::Base
	has_many :tickets
	has_many :teams

	def player_count
		tickets.includes(:summoner, :duo).where(status: "Completed").inject(0) {|sum, n| n.duo ? sum += 2 : sum += 1}
	end

	def seats_left
		self.total_players - player_count
	end

	def all_solos
		tickets.includes(:summoner).where(status: "Completed").where(duo_id: nil).map {|x| x.summoner}
	end

	def all_duos
		tickets.includes(:summoner, :duo).where(status: "Completed").where.not(duo_id: nil).map {|x| [x.summoner, x.duo]}
	end

	def get_elo
		all_sums = self.all_solos + self.all_duos.flatten
		without_elo = all_sums.select { |x| x unless x.elo }
		base_url = 'http://www.lolking.net/summoner/na/'
		nokogiri_request(without_elo, base_url)
	end

	def nokogiri_request(without_elo, base_url)
		without_elo.each do |sum_id|
			begin
				url = base_url + sum_id.summonerId.to_s
				update_summoner_elo(url)
			rescue => e
				Rails.logger.info "Lolking nokogiri_error: #{e}"
			end
		end
	end

	def update_summoner_elo(url)
		elo = 0
		raw_data = Nokogiri::HTML(open(URI.encode(url),{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,:read_timeout=>3}))
		elo = find_lolking_elo(raw_data).to_i
		Rails.logger.info "summoner/elo: #{sum_id.summonerName}/#{elo}"
		sum_id.update(elo: elo) if elo_valid?(elo)
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
