require 'test_helper'

class TournamentTest < ActiveSupport::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
	end

	test "player count returns corrent number" do
		assert_equal 40, @tournament.player_count
	end
end
