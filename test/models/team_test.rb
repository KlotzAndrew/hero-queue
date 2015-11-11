require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  def setup
		@tournament = tournaments(:tournament_sold)
		@tournament_with_teams = tournaments(:tournament_with_teams)
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

	test "absent summoners returns correct summoners" do
		team = @tournament_with_teams.teams.first
		assert_equal 5, team.summoners.count
		team.summoners.first.summoner_teams.where(team_id: team.id).first.update(absent: true)
		assert_equal 4, team.reload.summoners.count
	end

	test "assigned summoners returns correct summoners" do
		team = @tournament_with_teams.teams.first
		assert_equal 5, team.summoners.count
		team.summoners.first.summoner_teams.where(team_id: team.id).first.update(absent: true)
		assert_equal 5, team.reload.assigned_summoners.count
	end
end
