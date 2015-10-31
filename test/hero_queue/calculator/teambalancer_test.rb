require 'test_helper'
require_relative '../../../lib/hero_queue/calculator/teambalancer'

class TeambalancerTest < ActionController::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
	end

	test "correctly returns balanced teams" do
		teambalancer = Calculator::Teambalancer.new(@tournament.all_solos, @tournament.all_duos)
		teams = teambalancer.teambalance
		#corrent number of teams
		assert_equal teams.count, @tournament.total_teams
		#each team is 5 players
		teams.each do |x|
			assert_equal 5, x.flatten.count
		end
		# duos are still together
		total_duos = 0
		teams.each do |tickets|
			tickets.each do |players|
				if players.count > 1
					total_duos += 1
					assert_equal players.first[:id], players.last[:duo]
				end
			end
		end
		#correct number of duos
		assert_equal total_duos, @tournament.all_duos.count
		# returns balanced teams
		team_sums_sq = []
		team_means = teams.map {|x| x.flatten.map {|y| y[:elo]}}
		total_means = team_means.flatten.sum/team_means.count
		team_means.each {|x| team_sums_sq << (total_means - x.sum)**2 }
		teams_std = (team_sums_sq.sum/(teams.count - 1))**0.5		
		assert_includes 0..50, teams_std
		# #assert range maximum?
	end

	test "required summoner elo to build teams" do
	end
end