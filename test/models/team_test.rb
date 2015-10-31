require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  def setup
		@tournament = tournaments(:tournament_sold)
	end

	test "correctly builds teams" do
		teambalancer = Calculator::Teambalancer.new(@tournament.all_solos, @tournament.all_duos)
		teams = teambalancer.teambalance
		Team.build_teams(teams, @tournament.id)
		assert_equal @tournament.reload.teams.count, @tournament.total_teams
		@tournament.teams.each do |team|
			assert_equal team.summoners.count, 5
		end
	end
end
