module Calculator
	class Teambalancer
		attr_reader :solos
		attr_reader :duos
		attr_reader :total_teams

		Rails.env == "test" ? TIME_TOTAL = 1 : TIME_TOTAL = 20
		Rails.env == "test" ? TIME_MIXER = 1 : TIME_MIXER = 1

		def initialize(solos, duos)
			@solos = parse_solos(solos)
			@duos = parse_duos(duos)
			@total_teams = tally_players(solos, duos)
		end

		def teambalance(options = {})
			teams_hash = seed_teams
			teams_hash = optimize_teams(teams_hash)
			return teams_hash[:teams]
		end

		def seed
			teams_hash = seed_teams
		end

		def isolate_two_teams
			teams_hash = seed_teams
			teams_hash = extract_random_teams(teams_hash)
		end

		def shuffle_two_teams
			teams_hash = seed_teams
			teams_hash = extract_random_teams(teams_hash)
			teams_hash = suffle_extracted_teams(teams_hash)
		end

		def merge_back_teams
			teams_hash = seed_teams
			teams_hash = extract_random_teams(teams_hash)
			teams_hash = suffle_extracted_teams(teams_hash)
			teams_hash = merge_suffle_to_main(teams_hash)
		end

		def optimize_teams(teams_hash)
			st = Time.now.to_i
			candidate_std = 2000
			while (candidate_std >= 100) && (Time.now.to_i - st) < TIME_TOTAL
				teams_hash = shuffle_teams(teams_hash)
				candidate_std = teams_hash[:elo_sums].standard_deviation
			end
			return teams_hash
		end

		def shuffle_teams(teams_hash)
			teams_hash = extract_random_teams(teams_hash)
			teams_hash = suffle_extracted_teams(teams_hash)
			teams_hash = merge_suffle_to_main(teams_hash)
		end

		def merge_suffle_to_main(teams_hash)
			teams_hash[:teams_mix].each {|x| teams_hash[:teams] << x}
			teams_hash[:elo_sums_mix].each {|x| teams_hash[:elo_sums] << x}
			return teams_hash
		end

		def suffle_extracted_teams(teams_hash)
			st2 = Time.now.to_i
			while teams_hash[:teams_diff] <= (teams_hash[:elo_sums_mix].max - teams_hash[:elo_sums_mix].min) && (Time.now.to_i - st2) < TIME_MIXER
				teams_hash = shuffle_mixpot_teams(teams_hash)
			end
			return teams_hash
		end

		def extract_random_teams(teams_hash)
			teams_ab = pick_random_teams
			#clear elo sums
			0.upto(teams_hash[:elo_sums].count-1) {|x| teams_hash[:elo_sums][x] = 0}
			#move players
			teams_hash = move_solo_duo_to_mix(teams_hash, 2, teams_ab, "teams")
			teams_hash = move_solo_duo_to_mix(teams_hash, 1, teams_ab, "teams")
			delete_at_multi(teams_hash[:teams], teams_ab)
			delete_at_multi(teams_hash[:elo_sums], teams_ab)
			return teams_hash
		end

		def pick_random_teams
			team_a = rand(0..@total_teams-1)
			team_b = rand(0..@total_teams-1)
			while team_a == team_b
				team_b = rand(0..@total_teams-1)
			end
			return [team_a, team_b]
		end

		def shuffle_mixpot_teams(teams_hash)
			mix = teams_hash[:teams_mix][0] + teams_hash[:teams_mix][1]
			0.upto(teams_hash[:elo_sums_mix].count-1) {|x| teams_hash[:elo_sums_mix][x] = 0}
			0.upto(teams_hash[:teams_mix].count-1) {|x| teams_hash[:teams_mix][x] = []}	
			teams_hash = move_solo_duo_to_mix(teams_hash, 2, [0,1], "teams_mix", mix)
			teams_hash = move_solo_duo_to_mix(teams_hash, 1, [0,1], "teams_mix", mix)
			teams_hash[:teams_diff] = (teams_hash[:elo_sums_mix].max - teams_hash[:elo_sums_mix].min)
			return teams_hash
		end

		def move_solo_duo_to_mix(teams_hash, group_size, teams_ab, base_duck, mix = nil)
			mix ||= teams_hash[base_duck.to_sym][teams_ab[0]] + teams_hash[base_duck.to_sym][teams_ab[1]]
			mix.each do |player|
				teams_hash = move_play_to_mix(teams_hash, player) if player.count == group_size
			end
			teams_hash[:teams_diff] = teams_hash[:elo_sums_mix].max - teams_hash[:elo_sums_mix].min
			return teams_hash
		end

		def move_play_to_mix(teams_hash, player)
			random_team = random_team_with_space(teams_hash[:teams_mix], player.count)
			teams_hash[:teams_mix][random_team] << player
			player.each {|x| teams_hash[:elo_sums_mix][random_team]+= x[:elo] }
			return teams_hash
		end

		def random_team_with_space(teams_ary, group_size)
			total = teams_ary.count-1
			team_number = rand(0..total)
			while teams_ary[team_number].flatten.count >= (6-group_size)
				team_number = rand(0..total)
			end
			return team_number
		end	

		def seed_teams
			teams_hash = {
				teams: Array.new(@total_teams) {[]},
				elo_sums: Array.new(@total_teams) {0},
				teams_mix: Array.new(2){[]},
				elo_sums_mix: Array.new(2){0}
			}
			@duos.each do |player|
				random_team = random_team_with_space(teams_hash[:teams], player.count)
				teams_hash[:teams][random_team] << player
				teams_hash[:teams][random_team][0].each {|h| teams_hash[:elo_sums][random_team] += h[:elo]}
			end
			@solos.each do |player|
				random_team = random_team_with_space(teams_hash[:teams], player.count)
				teams_hash[:teams][random_team] << player
				teams_hash[:teams][random_team][0].each {|h| teams_hash[:elo_sums][random_team] += h[:elo]}
			end
			return teams_hash
		end

		def tally_players(solos, duos)
			(solos.count + duos.flatten.count)/5
		end

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

		def delete_at_multi(arr, index)
	    index = index.sort.reverse
	    index.each do |i|
	      arr.delete_at i
	    end
	    arr
	  end

	end
end