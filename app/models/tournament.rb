class Tournament < ActiveRecord::Base
	has_many :tickets
	has_many :teams
	belongs_to :series

	scope :upcoming, -> {where("start_date > ?", Time.now).order(start_date: :asc)}
	scope :past, -> {where("start_date < ?", Time.now).order(start_date: :asc)}

	def summoners
		sumoner_objs = []
		all_solos.flatten.each {|x| sumoner_objs << x}
		all_duos.flatten.each {|x| sumoner_objs << x}
		
		sumoner_objs
	end

	def player_count
		# Rails.cache.fetch("#{cache_key}/player_count") do
		if teams_approved
			teams.inject(0) {|sum, t| sum + t.summoners.count}
		else
			tickets.paid.includes(:duo).paid.inject(0) {|sum, n| n.duo ? sum += 2 : sum += 1}
		end
		# end
	end

	def seats_left
		self.total_players - player_count
	end

	def all_solos
		tickets.paid.includes(:summoner).paid.solo_tickets.map {|x| [x.summoner]}
	end

	def all_duos
		tickets.paid.includes(:summoner, :duo).paid.duo_tickets.map {|x| [x.summoner, x.duo]}
	end

	def update_summoners_elo
		summoners_array = self.all_solos.flatten + self.all_duos.flatten
		fetcher = Fetcher::Lolkingelo.new(summoners_array)
		fetcher.update_summoners_elo
	end

	def create_tournament_teams(options = {})
		teambalancer = Calculator::Teambalancer.new(self.all_solos, self.all_duos)
		teams = teambalancer.teambalance(options)
		build_new_teams(teams)
	end

	def approve_tournament_teams
		team_sums = self.teams.includes(:summoners).map {|x| x.summoners.inject(0) {|sum, n| sum + n.elo}}
		return false unless team_sums.standard_deviation < 75
		self.update!(teams_approved: true)
	end

	def team_statistics
		Rails.cache.fetch("#{cache_key}.team_statistics") do
			return false if self.teams.empty?
			team_sums = self.teams.includes(:summoners).map {|x| x.summoners.inject(0) {|sum, n| sum + n.elo}}
			{ 
				team_avg: team_sums.sum/team_sums.count,
				team_std: team_sums.standard_deviation.round(2),
				team_max: team_sums.max,
				team_min: team_sums.min,
			}
		end
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

	def build_new_teams(teams)
		teams.each do |team_array|
			team = self.teams.new
			team_array.flatten.each { |x| team.summoners << Summoner.find(x[:id]) }
			team.save
		end		
	end

end
