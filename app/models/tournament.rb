class Tournament < ActiveRecord::Base
	has_many :tickets
	has_many :teams

	def summoners
		sumoner_objs = []
		all_solos.flatten.each {|x| sumoner_objs << x}
		all_duos.flatten.each {|x| sumoner_objs << x}
		return sumoner_objs
	end

	def player_count
		tickets.includes(:duo).paid.inject(0) {|sum, n| n.duo ? sum += 2 : sum += 1}
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

	def update_summoners_elo
		fetcher = Fetcher::Lolkingelo.new(self)
	end

	def create_tournament_teams(options = {})
		ticket_hashes = tickets_to_teambalancer_hash
		teambalancer = Calculator::Teambalancer.new(ticket_hashes[:solos], ticket_hashes[:duos])
		teams = teambalancer.teambalance(options)
		build_new_teams(teams)
	end

	def team_statistics
		return false if self.teams.empty?
		team_sums = self.teams.includes(:summoners).map {|x| x.summoners.inject(0) {|sum, n| sum + n.elo}}
		{ 
			team_avg: team_sums.sum/team_sums.count,
			team_std: calculate_std(team_sums).round(2),
			team_max: team_sums.max,
			team_min: team_sums.min,
			# team_tscore: 1.67
		}
	end

	def calculate_std(team_sums)
		team_sums_sq = []
		team_mean = team_sums.sum/team_sums.count
		team_sums.each do |x|
			team_sums_sq << (team_mean - x)**2
		end
		std = (team_sums_sq.sum/(teams.count - 1))**0.5
	end

	class << self
		def legacy
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

	private

	def under_max_team_limit

	end

	def build_new_teams(teams)
		teams.each do |team_array|
			team = self.teams.new
			team_array.flatten.each { |x| team.summoners << Summoner.find(x[:id]) }
			team.save
		end		
	end

	def tickets_to_teambalancer_hash
		ticket_hashes = {}
		ticket_hashes[:solos] = self.all_solos.map do |x|
		 [{
		  	id: x.first.id,
		  	elo: x.first.elo
		  }]
		end
		ticket_hashes[:duos] = self.all_duos.map do |x,y|
		 [{
		  	id: x.id,
		  	elo: x.elo,
		  	duo: y.id
		  },
		  {
		  	id: y.id,
		  	elo: y.elo,
		  	duo: x.id
		  }]
		end
		return ticket_hashes
	end

end
