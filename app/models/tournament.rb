class Tournament < ActiveRecord::Base
	has_many :tickets
	has_many :teams

	def player_count
		tickets.includes(:summoner, :duo).paid.inject(0) {|sum, n| n.duo ? sum += 2 : sum += 1}
	end

	def seats_left
		self.total_players - player_count
	end

	def all_solos
		tickets.includes(:summoner).paid.solo_tickets.map {|x| x.summoner}
	end

	def all_duos
		tickets.includes(:summoner, :duo).paid.duo_tickets.map {|x| [x.summoner, x.duo]}
	end

	def build_teams
		return false if teams_closed? == true
		return false if missing_elos? == true
		teambuilder
	end

	def team_stats
		elo_array = []
		teams.each do |team|
			elo_array << team.summoners.map {|x| x.elo }
		end
		team_mean = elo_array.flatten.sum/teams.count
		Rails.logger.info "team_mean: #{team_mean}"
		team_sums_sq = []
		elo_array.each do |x|
			Rails.logger.info "elo_array.each: #{x}"
			team_sums_sq << (team_mean - x.sum)**2
		end
		Rails.logger.info "team_sums_sq: #{team_sums_sq}"
		return {
			team_std: (team_sums_sq.sum/(teams.count - 1))**0.5,
			team_mean: team_mean/5
		}
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

	def teams_closed?
		return true if seats_left > 0
		return true if teams.count == total_teams
	end

	def missing_elos?
		check_elo = Proc.new {|x| return true if x.elo.nil?}
		all_solos.each(&check_elo)
		all_duos.flatten.each(&check_elo)
	end

	def teambuilder
		cand_teams = []
		cand_std = 2000
		st = Time.now.to_i

		#populate teams
		p_solos = all_solos
		p_duos = all_duos
		all_players = all_solos + all_duos.flatten
		ids = all_players.map {|x| x.elo}
		Rails.logger.info "MAIN! #{ids}"
		Rails.logger.info "TCIKETS! #{tickets.where(status: "Completed").map {|x| [x.summoner_id, x.duo_id]}}"
		Rails.logger.info "duplicates! #{ids.select{|item| ids.count(item) > 1}.uniq}"

		temp_teams = []
		total_teams.times do |x|
			temp_teams << []
		end

		p_duos.each do |duo|
			team_num = rand(0..total_teams-1)
			while temp_teams[team_num].flatten.count >= 4
				team_num = rand(0..total_teams-1)
			end

			temp_teams[team_num] << duo
		end

		p_solos.each do |solo|
			team_num = rand(0..total_teams-1)
			while temp_teams[team_num].flatten.count >= 5
				team_num = rand(0..total_teams-1)
			end
			temp_teams[team_num] << solo
		end

		temp_teams.each do |team_array|
			Rails.logger.info "TEAM_ARRAY: #{team_array}"
			team = Team.create
			team_array.flatten.each do |x|
				team.summoners << x
			end
			teams << team
		end
	end
end
