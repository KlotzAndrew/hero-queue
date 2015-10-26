class Tournament < ActiveRecord::Base
	has_many :tickets
	has_many :teams
	# include Sortinghat
	
	def player_count
		tickets.includes(:summoner, :duo).paid.inject(0) {|sum, n| n.duo ? sum += 2 : sum += 1}
	end

	def seats_left
		self.total_players - player_count
	end

	def all_solos
		tickets.includes(:summoner).paid.solo_tickets.map {|x| [x.summoner]}
	end

	def all_duos
		tickets.includes(:summoner, :duo).paid.duo_tickets.map {|x| [x.summoner, x.duo]}
	end

	#plan to remove this when 4+ new tournaments
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

	private

end
