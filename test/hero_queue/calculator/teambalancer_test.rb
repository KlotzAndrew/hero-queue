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
		assert_equal @tournament.total_teams, teams.count
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
		team_means = teams.map {|x| x.flatten.map {|y| y[:elo]}}.map {|x| x.sum}
		assert_includes 0..150, team_means.standard_deviation
	end
end