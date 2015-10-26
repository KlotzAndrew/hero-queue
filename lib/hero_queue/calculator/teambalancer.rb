module Calculator
	class Teambalancer
		attr_reader :solos
		attr_reader :duos

		def initialize(solos, duos)
			@solos = solos
			@duos = duos
		end

	def teambalance
		cand_std = 2000
		#populate teams
		p_solos, p_duos = @solos, @duos
		temp_teams = [] 
		number_of_teams = (@solos.count + @duos.flatten.count)/5
		number_of_teams.times { |x| temp_teams << [] }
		populate_array(p_duos, temp_teams)
		populate_array(p_solos, temp_teams)
		#itterate with mixing pot
		st = Time.now.to_i
		while cand_std > 100 && Time.now.to_i - st < 1 do
			mixing_pot = build_mixing_pot(temp_teams)
			max_team_mmr = mini_max = shuffle_threshhold(temp_teams)
			#shuffle mixing pot teams
			mm_st = Time.now.to_i
			while mini_max >= max_team_mmr && Time.now.to_i - mm_st < 1 do
				new_teams = shuffle_mixpot_teams(mixing_pot)
				mini_max = new_teams.map {|x| x.flatten.sum {|y| y[:elo]}}.max
				Rails.logger.info "mini_max after: #{mini_max}"
			end
			#add mix back to teams
			new_teams.each {|mixed_team| temp_teams << mixed_team}
			cand_std = calculate_std(temp_teams)
			Rails.logger.info "cand_std: #{cand_std}"
		end
		build_finished_teams(temp_teams)
	end

	def shuffle_threshhold(temp_teams)
		temp_teams.map {|x| x.flatten.map {|y| y[:elo]}}.max.sum
	end

	def build_mixing_pot(temp_teams)
		mixing_pot = []
		move_extreme_team(temp_teams, mixing_pot, "max")
		move_extreme_team(temp_teams, mixing_pot, "min")
		return mixing_pot
	end

	def shuffle_mixpot_teams(pot)
		new_teams = [[],[]]
		mix_duos = players_from_pot(pot, 2)
		populate_array(mix_duos, new_teams)
		mix_solos = players_from_pot(pot, 1)
		populate_array(mix_solos, new_teams)
		return new_teams
	end

	def move_extreme_team(base, target, extreme)
		team_means = base.map {|x| x.flatten.map {|y| y[:elo]}}
		if extreme == "min" then team_value = team_means.min else team_value = team_means.max end
		index_value = extreme_team_index(team_means, team_value.sum)
		target << base[index_value]
		base.delete_at(index_value)
	end

	def build_finished_teams(temp_teams)
		# temp_teams.each do |team_array|
		# 	team = Team.create
		# 	team_array.flatten.each { |x| team.summoners << x }
		# 	teams << team
		# end
		return temp_teams
	end

	def calculate_std(temp_teams)
		team_sums_sq = []
		team_means = temp_teams.map {|x| x.flatten.map {|y| y[:elo]}}
		total_means = team_means.flatten.sum/team_means.count
		team_means.each {|x| team_sums_sq << (total_means - x.sum)**2 }
		return (team_sums_sq.sum/(temp_teams.count - 1))**0.5
	end

	def extreme_team_index(base, value)
		the_index = nil
		0.upto(base.count-1) { |x| the_index = x if base[x].sum == value }
		return the_index
	end

	def players_from_pot(pot, pair_size)
		mixer = []
		pot.each do |parse_team| 
			parse_team.each {|players| mixer << players if players.count == pair_size }
		end
		return mixer
	end

	#moves players from target into base array[array]
	def populate_array(base, target)
		base.each do |players|
			team_num = rand(0..target.count-1)
			while target[team_num].flatten.count >= (6-players.count)
				team_num = rand(0..target.count-1)
			end
			target[team_num] << players
		end
	end
	end
end