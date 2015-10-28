require 'test_helper'

class TournamentTest < ActiveSupport::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
		@tournament_unsold = tournaments(:tournament_unsold)
	end

	test "returns correct team statistics" do
		#build teams on fixtures
		all_summoners = @tournament.all_solos + @tournament.all_duos.flatten
		all_summoners.in_groups_of(5) do |summoners|
			team = Team.create(tournament_id: @tournament.id)
			summoners.each {|summoner| team.summoners << summoner}
		end
		stats = @tournament.team_statistics
		assert_equal stats[:team_avg], 10625
		assert_equal stats[:team_std], 2098.64	
		assert_equal stats[:team_max], 13700
		assert_equal stats[:team_min], 7600
		# assert_equal stats[:team_tscore], 2000
	end

	test "tournament has a limit on number of teams" do
		@tournament.total_teams.times do |x| 
			@tournament.teams << @tournament.teams.create
		end
		assert_equal @tournament.total_teams, @tournament.teams.count
		@tournament.teams << @tournament.teams.create
		assert_equal @tournament.total_teams, @tournament.teams.count
	end
	
	test "player_count returns corrent number" do
		assert_equal 40, @tournament.player_count
	end

	test "seats_left returns corrent number" do
		assert_equal 0, @tournament.seats_left
	end

	test "all_solos returns corrent number" do
		assert_equal 16, @tournament.all_solos.count
	end

	test "all_duos returns corrent number" do
		assert_equal 12, @tournament.all_duos.count
		assert_equal 24, @tournament.all_duos.flatten.count
	end
end
