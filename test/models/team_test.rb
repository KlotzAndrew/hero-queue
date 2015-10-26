require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  def setup
		@tournament = tournaments(:tournament_sold)
	end

	test "correctly builds teams" do
		solos = @tournament.all_solos.map do |x|
		 [{
		  	id: x.first.id,
		  	elo: x.first.elo
		  }]
		end
		duos = @tournament.all_duos.map do |x,y|
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

		teambalancer = Calculator::Teambalancer.new(solos, duos)
		teams = teambalancer.teambalance
		Team.build_teams(teams, @tournament.id)
		assert_equal @tournament.reload.teams.count, @tournament.total_teams
	end
end
