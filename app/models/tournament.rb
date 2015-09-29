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
			temp_teams[team_num] << [solo]
		end
		#itterate with mixing pot
		while cand_std > 100 && Time.now.to_i - st < 10 do
			Rails.logger.info "temp_teams starting: #{temp_teams.count}"
			max, min = nil, nil
			#move max players into mixing pot
			mixing_pot = []
			new_teams = [[],[]]
			team_means = temp_teams.map {|x| x.flatten.map {|y| y.elo}}
			max_team_mmr, mini_max = team_means.max.sum, team_means.max.sum
			0.upto(team_means.count-1) do |x| 
				if team_means[x].sum == team_means.max.sum
					max = x
					break
				end
			end
			mixing_pot << temp_teams[max]
			temp_teams.delete_at(max)
			Rails.logger.info "temp_teams -1: #{temp_teams.count}"
			#move min players into mixing pot
			team_means = temp_teams.map {|x| x.flatten.map {|y| y.elo}}
			0.upto(team_means.count-1) do |x| 
				if team_means[x].sum == team_means.min.sum
					min = x
					break
				end
			end
			mixing_pot << temp_teams[min]
			temp_teams.delete_at(min)
			Rails.logger.info "min_max: #{min}-#{max}"
			Rails.logger.info "mixing_pot.flatten.count: #{mixing_pot.flatten.count}"
			Rails.logger.info "temp_teams -2: #{temp_teams.count}"

			mm_st = Time.now.to_i
			while mini_max >= max_team_mmr && Time.now.to_i - mm_st < 5
				new_teams = [[],[]]
				#mix in duos
				Rails.logger.info "mixing_pot: #{mixing_pot}"
				mix_duos = []
				mixing_pot.each do |parse_team| 
					parse_team.each do |players|
						if players.count > 1
							mix_duos << players
						end
					end
				end
				Rails.logger.info "mix_duos: #{mix_duos.count}"
				mix_duos.each do |duo|
					team_num = rand(0..new_teams.count-1)
					while new_teams[team_num].flatten.count >= 4
						team_num = rand(0..new_teams.count-1)
					end
					Rails.logger.info "mix this duo: #{duo}"
					new_teams[team_num] << duo
				end
				new_teams.each do |xa| 
					Rails.logger.info "new_teams.count duos: #{xa.flatten.count}"
				end
				#mix in solos
				mix_solos = []
				mixing_pot.each do |parse_team| 
					parse_team.each do |players|
						if players.count == 1
							mix_solos << players
						end
					end
				end
				Rails.logger.info "mix_solos: #{mix_solos.count}"
				mix_solos.each do |solos|
					team_num = rand(0..new_teams.count-1)
					while new_teams[team_num].flatten.count >= 5
						team_num = rand(0..new_teams.count-1)
					end
					Rails.logger.info "mix this solo: #{solos}"
					new_teams[team_num] << solos
				end
				new_teams.each do |xa| 
					Rails.logger.info "new_teams.count solos: #{xa.flatten.count}"
				end
				Rails.logger.info "new_teams aft solos: #{new_teams}"
				mini_max_demo = new_teams.map {|x| x.flatten.sum {|y| y.elo}}
				Rails.logger.info "mini_max_demo: #{mini_max_demo}"
				Rails.logger.info "mini_max: #{mini_max}"
				Rails.logger.info "mini_max: #{max_team_mmr}"
			end
			#add mix back to teams
			new_teams.each {|add_mix| temp_teams << add_mix}
			Rails.logger.info "temp_teams.count #{temp_teams.count}"
			#recalculate std
			team_means = temp_teams.map {|x| x.flatten.map {|y| y.elo}}
			total_means = team_means.flatten.sum/team_means.count
			Rails.logger.info "team_mean: #{team_means}"
			team_sums_sq = []
			team_means.each do |x|
				Rails.logger.info "elo_array.each: #{x}"
				team_sums_sq << (total_means - x.sum)**2
			end
			Rails.logger.info "team_sums_sq.sum: #{team_sums_sq.sum}"
			Rails.logger.info "teams.count: #{temp_teams.count}"
			cand_std = (team_sums_sq.sum/(temp_teams.count - 1))**0.5
			Rails.logger.info "cand_std: #{cand_std}"
		end

		#build finished team objects
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
