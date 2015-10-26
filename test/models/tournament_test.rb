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
end
