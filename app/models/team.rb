class Team < ActiveRecord::Base
	belongs_to :tournament
	has_many :summoner_teams
	has_many :summoners, :through => :summoner_teams


	def self.build_teams(teams, tournament_id)
		teams.each do |team_array|
			team = Team.create(tournament_id: tournament_id)
			team_array.flatten.each { |player| team.summoners << Summoner.find(player[:id]) }
		end
	end

	# => gaurd clauses and validations for teams
	# def build_teams
	# 	return false if teams_closed? == true
	# 	return false if missing_elos? == true
	# 	teambuilder
	# end

	# def teams_closed?
	# 	return true if seats_left > 0
	# 	return true if teams.count == total_teams
	# end

	# def missing_elos?
	# 	check_elo = Proc.new {|x| return true if x.elo.nil?}
	# 	all_solos.flatten.each(&check_elo)
	# 	all_duos.flatten.each(&check_elo)
	# end

	# => displays stats about teams
	# def team_stats
	# 	elo_array = []
	# 	teams.each do |team|
	# 		elo_array << team.summoners.map {|x| x.elo }
	# 	end
	# 	team_mean = elo_array.flatten.sum/teams.count
	# 	Rails.logger.info "team_mean: #{team_mean}"
	# 	team_sums_sq = []
	# 	elo_array.each do |x|
	# 		Rails.logger.info "elo_array.each: #{x}"
	# 		team_sums_sq << (team_mean - x.sum)**2
	# 	end
	# 	Rails.logger.info "team_sums_sq: #{team_sums_sq}"
	# 	return {
	# 		team_std: (team_sums_sq.sum/(teams.count - 1))**0.5,
	# 		team_mean: team_mean/5
	# 	}
	# end	
end
