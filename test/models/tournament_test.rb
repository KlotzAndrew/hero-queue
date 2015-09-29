require 'test_helper'

class TournamentTest < ActiveSupport::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
		@tournament_unsold = tournaments(:tournament_unsold)
	end

	#instance scopes
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

	#teambuilder
	test "needs full roster to build teams" do
		@tournament_unsold.build_teams
		assert_equal 0, @tournament_unsold.reload.teams.count
	end

	test "does not build teams if teams full" do
		@tournament.total_teams.times do |x|
			@tournament.teams << Team.create
		end
		@tournament = @tournament.reload
		assert_equal @tournament.total_teams, @tournament.teams.count
		assert_equal false, @tournament.build_teams
	end

	test "required summoner elo to build teams" do
		assert_equal 0, @tournament.reload.teams.count
		assert_equal false, @tournament.build_teams
	end

	test "builds teams correctly" do
		all_players = @tournament.all_solos + @tournament.all_duos.flatten
		i = 1000
		all_players.each do |x|
			x.update(elo: i)
			if i < 1500
				i+=75
			elsif i < 2000
				i+=20
			else
				i+=40
			end
		end
		@tournament.build_teams
		@tournament = @tournament.reload

		#all teams are created
		assert_equal @tournament.total_teams, @tournament.teams.count
		#each team is 5 players
		@tournament.teams.each do |x|
			assert_equal 5, x.summoners.count
		end
		#each player is on a team (once)
		@tournament.all_solos.each do |x|
			assert_equal 1, x.teams.count
		end
		@tournament.all_duos.flatten.each do |x|
			assert_equal 1, x.teams.count
		end
		#duos are still together
		@tournament.all_duos.each do |x,y|
			assert_equal x.teams.first, y.teams.first
		end
		#returns correct stats
		assert_equal 1754, @tournament.team_stats[:team_mean]
		#is balanced
		assert_includes 0..100, @tournament.team_stats[:team_std]
		#assert range maximum?
	end
end
