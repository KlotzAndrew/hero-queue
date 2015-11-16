class Tournament < ActiveRecord::Base
	has_many :tickets
	has_many :teams
	belongs_to :series

	scope :upcoming, -> {where("start_date > ?", Time.now).order(start_date: :asc)}
	scope :past, -> {where("start_date < ?", Time.now).order(start_date: :asc)}

	has_many :ringer_tickets, -> {ringers}, :class_name => 'Ticket'
	has_many :ringers, :source => :summoner, :through => :ringer_tickets

	has_many :tournament_participations
	has_many :summoners, :through => :tournament_participations

	has_many :solo_players, -> {solos}, :class_name => "TournamentParticipation"
	has_many :all_solos, :source => :summoner, :through => :solo_players

	def player_count
		# Rails.cache.fetch("#{cache_key}/player_count") do
			self.tournament_participations.count
		# end
		# 	if teams_approved
		# 		teams.inject(0) {|sum, t| sum + t.summoners.count}
		# 	else
		# 		tickets.paid.includes(:duo).paid.inject(0) {|sum, n| n.duo ? sum += 2 : sum += 1}
		# 	end
	end

	def seats_left
		self.total_players - player_count
	end

	def all_duos
		self.tournament_participations.duos
	end

	def all_solo_tickets
		tickets.paid.includes(:summoner).paid.solo_tickets.map {|x| [x.summoner]}
	end

	def all_duo_tickets
		tickets.paid.includes(:summoner, :duo).paid.duo_tickets.map {|x| [x.summoner, x.duo]}
	end

	def update_summoners_elo
		summoners_array = self.summoners
		fetcher = Fetcher::Lolkingelo.new(summoners_array)
		fetcher.update_summoners_elo
	end

	def create_tournament_teams(options = {})
		teambalancer = Calculator::Teambalancer.new(self.all_solos, self.all_duos)
		teams = teambalancer.teambalance(options)
		Team.build_teams(teams, self.id)
	end

	def approve_tournament_teams
		team_sums = self.teams.includes(:summoners).map {|x| x.summoners.inject(0) {|sum, n| sum + n.elo}}
		return false unless team_sums.standard_deviation < 75
		self.update!(teams_approved: true)
	end

	def team_statistics
		Rails.cache.fetch("#{cache_key}.team_statistics") do
			return false if self.teams.empty?
			team_sums = self.teams.includes(:summoners).map {|x| x.summoners.map(&:elo).sum }
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

end
