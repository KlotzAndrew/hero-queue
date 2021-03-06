require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  def setup
  	@team = Team.new(
    	tournament_id: 1)

		@tournament = tournaments(:tournament_sold)
		@tournament_with_teams = tournaments(:tournament_with_teams)
	end

	test "should be valid" do
		assert @team.valid?
	end

	test "tournament_id should be present" do
		@team.tournament_id = nil
		assert_not @team.valid?
	end

	test "teams should not exceed max team limit" do
		team = @tournament_with_teams.teams.new
		assert_not team.save
	end

	test "correctly builds teams" do
		teambalancer = Calculator::Teambalancer.new(@tournament.all_solos, @tournament.all_duos)
		teams = teambalancer.teambalance
		Team.build_teams(teams, @tournament.id)
		#correct number of teams
		assert_equal @tournament.reload.teams.count, @tournament.total_teams
		#teams are correct size
		@tournament.teams.each do |team|
			assert_equal team.summoners.count, 5
		end		
		#teams have names
		@tournament.teams.each do |team|
			assert team.name, msg = "team is missing a name"
		end
	end

	test "absent summoners returns correct summoners" do
		team = @tournament_with_teams.teams.first
		assert_equal 5, team.summoners.count
		team.summoners.first.tournament_participations.where(team_id: team.id).first.update(absent: true)
		assert_equal 4, team.reload.summoners.count
	end

	test "assigned summoners returns correct summoners" do
		team = @tournament_with_teams.teams.first
		assert_equal 5, team.summoners.count
		team.summoners.first.tournament_participations.where(team_id: team.id).first.update(absent: true)
		assert_equal 5, team.reload.assigned_summoners.count
	end
end