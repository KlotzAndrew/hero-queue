module Calculator
	class Teambalancer
		attr_reader :solos
		attr_reader :duos
		attr_reader :total_teams

		Rails.env == "test" ? TIME_TOTAL = 1 : TIME_TOTAL = 20
		Rails.env == "test" ? TIME_MIXER = 0.5 : TIME_MIXER = 1
		TARGET_STD = 10
		TEAM_SIZE = 5

		def initialize(solos, duos)
			@solos = parse_solos(solos)
			@duos = parse_duos(duos)
			@total_teams = tally_players(solos, duos)
		end

		def teambalance(options = {})
			teams_hash = seed_teams(@total_teams, @solos, @duos)
			teams_hash = optimize_teams(teams_hash)[:teams]
		end

		def optimize_teams(teams_hash)
			st = Time.now.to_i
			candidate_std = teams_hash[:elo_sums].standard_deviation
			i = 0
			while (candidate_std >= TARGET_STD) && (Time.now.to_i - st) < TIME_TOTAL
				i +=1
				teams_hash = shuffle_teams(teams_hash)
				candidate_std = teams_hash[:elo_sums].standard_deviation
				Rails.logger.info "ELOS: #{teams_hash[:elo_sums]}"
				Rails.logger.info "candidate_std: #{candidate_std} | #{i}"
			end
			return teams_hash
		end

		def shuffle_teams(teams_hash)
			random_teams_index = pick_random_teams
			teams_new = calc_new_teams(teams_hash, random_teams_index)
			if teams_new
				Rails.logger.info "accepted teams"
				teams_hash = remove_teams_old(teams_hash, random_teams_index)
				teams_hash = merge_teams_to_main(teams_hash, teams_new, random_teams_index)
			end
			return teams_hash
		end

		def calc_new_teams(teams_hash, random_teams_index)
			mix = Array.new
			random_teams_index.each {|x| mix = mix + teams_hash[:teams][x]}
			candidate = baseline = [teams_hash[:elo_sums][random_teams_index[1]], teams_hash[:elo_sums][random_teams_index[0]]].range
			teams_new = {}
			5.times do |x|
				teams_new = itterate_teams(mix)
				candidate = teams_new[:elo_sums].range
			end
			Rails.logger.info "diff: #{candidate} | #{baseline}"
			return nil if candidate >= baseline
			return teams_new
		end

		def remove_teams_old(teams_hash, random_teams_index)
			delete_at_multi(teams_hash[:teams], random_teams_index)
			delete_at_multi(teams_hash[:elo_sums], random_teams_index)
			teams_hash
		end

		def itterate_teams(mix)
			total_teams = mix.flatten.count/TEAM_SIZE
			solos_duos = mix.partition {|x| x.count > 1}
			teams_new = seed_teams(total_teams, solos_duos[1], solos_duos[0])
		end

		def merge_teams_to_main(teams_hash, teams_new, random_teams_index)
			teams_new[:teams].each {|x| teams_hash[:teams] << x}
			teams_new[:elo_sums].each {|x| teams_hash[:elo_sums] << x}
			return teams_hash
		end

		def pick_random_teams
			a = b = rand(0..@total_teams-1)
			b = rand(0..@total_teams-1) while a == b
			return [a, b]
		end

		def random_team_with_space(teams_ary, group_size)
			total = teams_ary.count-1
			team_number = rand(0..total)
			while teams_ary[team_number].flatten.count >= (6-group_size)
				team_number = rand(0..total)
			end
			return team_number
		end	

		def seed_teams(total_teams, solos, duos)
			new_teams_hash = {
				teams: Array.new(total_teams) {[]},
				elo_sums: Array.new(total_teams) {0},
			}
			duos.each do |player|
				random_team = random_team_with_space(new_teams_hash[:teams], player.count)
				new_teams_hash[:teams][random_team] << player
				new_teams_hash[:elo_sums][random_team] += (player[0][:elo] + player[1][:elo])
			end
			solos.each do |player|
				random_team = random_team_with_space(new_teams_hash[:teams], player.count)
				new_teams_hash[:teams][random_team] << player
				new_teams_hash[:elo_sums][random_team] += player[0][:elo]
			end
			return new_teams_hash
		end

		def tally_players(solos, duos)
			(solos.count + duos.flatten.count)/TEAM_SIZE
		end

		def parse_solos(solos)
			solos_hashed = solos.map do |x|
			 [{
			  	id: x.id,
			  	elo: x.elo
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