module Calculator
	class Teambalancer
		attr_reader :solos
		attr_reader :duos
		attr_reader :total_teams
		
		def initialize(solos, duos)
			@solos = parse_solos(solos)
			@duos = parse_duos(duos)
			@total_teams = tally_players(solos, duos)
		end

	def teambalance(options = {})
		time_total = options[:time_total] || 60
		time_mixer = options[:time_mixer] || 1
		if Rails.env == "test"
			time_total = 1
			time_mixer = 1
		end

		teams_ary = seed_bracket
		team_elo_sum_ary = seed_elo_bracket
		candidate_std = 2000
		seed_teams(teams_ary, team_elo_sum_ary)
		st = Time.now.to_i
		while (candidate_std >= 100) && (Time.now.to_i - st) < time_total
			opt_hash = optimize_teams(teams_ary, team_elo_sum_ary)
			Rails.logger.info "loop1d #{opt_hash}"
			teams_ary = opt_hash[:teams_ary]
			team_elo_sum_ary = opt_hash[:team_elo_sum_ary]
			candidate_std = team_elo_sum_ary.map {|x| x.first}.standard_deviation
			Rails.logger.info "loop1 #{candidate_std}"
		end
		Rails.logger.info "final #{teams_ary}"
		return teams_ary
	end

	def optimize_teams(teams_ary, team_elo_sum_ary)
		Rails.logger.info "loop1a #{team_elo_sum_ary}"
		mix_max = team_elo_sum_ary.max[0]
		mixing_pot = extract_extreme_teams(teams_ary,team_elo_sum_ary)
		Rails.logger.info "loop1b #{team_elo_sum_ary}"
		hash = mix_into_teams(mixing_pot, mix_max, teams_ary, team_elo_sum_ary)
		teams_ary = teams_ary + hash[:new_teams_ary]
		team_elo_sum_ary = team_elo_sum_ary + hash[:new_elo_ary]
		opt_hash = {
			teams_ary: teams_ary,
			team_elo_sum_ary: team_elo_sum_ary
		}
		Rails.logger.info "loop1c #{team_elo_sum_ary}"
		return opt_hash
	end

	def extract_extreme_teams(teams_ary,team_elo_sum_ary)
		max_index = team_elo_sum_ary.find_index(team_elo_sum_ary.max)
		mixing_pot = teams_ary[max_index]
		teams_ary.delete_at(max_index)
		team_elo_sum_ary.delete_at(max_index)

		min_index = team_elo_sum_ary.find_index(team_elo_sum_ary.min)
		mixing_pot += teams_ary[min_index]
		teams_ary.delete_at(min_index)
		team_elo_sum_ary.delete_at(min_index)

		return mixing_pot
	end

	def mix_into_teams(mixing_pot, mix_max, teams_ary, team_elo_sum_ary)
		temp_max = 99999
		st2 = Time.now.to_i
		new_teams_ary ||= [[],[]]
		new_elo_ary ||= [[0],[0]]
		Rails.logger.info "loop3 #{mix_max}"
		while (temp_max > mix_max) && (Time.now.to_i - st2) < 1
			Rails.logger.info "loop3a"
			new_teams_ary = [[],[]]
			new_elo_ary = [[0],[0]]
			mix_duos = mixing_pot.select {|x| x.size > 1}
			mix_solos = mixing_pot.select {|x| x.size == 1}
			Rails.logger.info "loop3b"
			push_players_to_teams(mix_duos, new_teams_ary, new_elo_ary)
			push_players_to_teams(mix_solos, new_teams_ary, new_elo_ary)
			temp_max = new_elo_ary.max[0]
			Rails.logger.info "loop4: #{mix_max}"
		end
		Rails.logger.info "loop4a: #{new_elo_ary}"
		# teams_ary = teams_ary + new_teams_ary
		# team_elo_sum_ary = team_elo_sum_ary + new_elo_ary
		hash = {}
		hash[:new_teams_ary] = new_teams_ary
		hash[:new_elo_ary] = new_elo_ary
		return hash
		Rails.logger.info "loop4b: #{team_elo_sum_ary}"
	end

	def push_players_to_teams(players, new_teams_ary, new_elo_ary)
		players.each do |player|
			Rails.logger.info "loop6a: #{player}"
			random_team = random_team_with_space(new_teams_ary, player.count, 2)
			new_teams_ary[random_team] << player
			new_teams_ary[random_team][0].each {|h| new_elo_ary[random_team][0] += h[:elo]}
		end
	end

	def seed_elo_bracket
		ary = []
		(@total_teams).times {|x| ary << [0]}
		return ary
	end

	def seed_bracket
		ary = []
		(@total_teams).times {|x| ary << []}
		return ary
	end

	def seed_teams(teams_ary, team_elo_sum_ary)
		@duos.each do |player|
			random_team = random_team_with_space(teams_ary, player.count, @total_teams)
			teams_ary[random_team] << player
			teams_ary[random_team][0].each {|h| team_elo_sum_ary[random_team][0] += h[:elo]}
		end
		@solos.each do |player|
			random_team = random_team_with_space(teams_ary, player.count, @total_teams)
			teams_ary[random_team] << player
			teams_ary[random_team][0].each {|h| team_elo_sum_ary[random_team][0] += h[:elo]}
		end
	end

	def random_team_with_space(teams_ary, people, total)
		team_number = rand(0..total-1)
		while teams_ary[team_number].flatten.count >= (6-people)
			Rails.logger.info "loop5a: #{team_number}"
			Rails.logger.info "loop5a: #{teams_ary} | #{people} | #{total}"
			team_number = rand(0..total-1)
		end
		return team_number
	end


	def tally_players(solos, duos)
		(solos.count + duos.flatten.count)/5
	end

	# => below is old

	# def shuffle_threshhold(teams)
	# 	teams.map {|x| x.flatten.map {|y| y[:elo]}}.max.sum
	# end

	# def build_mixing_pot(teams)
	# 	mixing_pot = []
	# 	move_extreme_team(teams, mixing_pot, "max")
	# 	move_extreme_team(teams, mixing_pot, "min")
	# 	return mixing_pot
	# end

	# def shuffle_mixpot_teams(pot)
	# 	new_teams = [[],[]]
	# 	mix_duos = players_from_pot(pot, 2)
	# 	populate_array(mix_duos, new_teams)
	# 	mix_solos = players_from_pot(pot, 1)
	# 	populate_array(mix_solos, new_teams)
	# 	return new_teams
	# end

	# def move_extreme_team(base, target, extreme)
	# 	team_means = base.map {|x| x.flatten.map {|y| y[:elo]}}
	# 	if extreme == "min" then team_value = team_means.min else team_value = team_means.max end
	# 	index_value = extreme_team_index(team_means, team_value.sum)
	# 	target << base[index_value]
	# 	base.delete_at(index_value)
	# end

	# def build_finished_teams(teams)
	# 	# teams.each do |team_array|
	# 	# 	team = Team.create
	# 	# 	team_array.flatten.each { |x| team.summoners << x }
	# 	# 	teams << team
	# 	# end
	# 	return teams
	# end

	# def calculate_std(teams)
	# 	team_sums_sq = []
	# 	team_means = teams.map {|x| x.flatten.map {|y| y[:elo]}}
	# 	total_means = team_means.flatten.sum/team_means.count
	# 	team_means.each {|x| team_sums_sq << (total_means - x.sum)**2 }
	# 	return (team_sums_sq.sum/(teams.count - 1))**0.5
	# end

	# def extreme_team_index(base, value)
	# 	the_index = nil
	# 	0.upto(base.count-1) { |x| the_index = x if base[x].sum == value }
	# 	return the_index
	# end

	# def players_from_pot(pot, pair_size)
	# 	mixer = []
	# 	pot.each do |parse_team| 
	# 		parse_team.each {|players| mixer << players if players.count == pair_size }
	# 	end
	# 	return mixer
	# end

	# #moves players from target into base array[array]
	# def populate_array(base, target)
	# 	base.each do |players|
	# 		team_num = rand(0..target.count-1)
	# 		while target[team_num].flatten.count >= (6-players.count)
	# 			team_num = rand(0..target.count-1)
	# 		end
	# 		target[team_num] << players
	# 	end
	# end

		def parse_solos(solos)
			solos_hashed = solos.map do |x|
			 [{
			  	id: x.first.id,
			  	elo: x.first.elo
			  }]
			end
		end
		def parse_duos(duos)
			duos_hashed = duos.map do |x,y|
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
		end

	end
end