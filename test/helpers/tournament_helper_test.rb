require 'test_helper'
 
class TournamentHelperTest < ActionView::TestCase
	include TournamentsHelper
	def setup
		@tournament = tournaments(:tournament_sold)
	end

	test "seats remainng returns correct number of seats" do
		assert_equal 40, seats_taken(@tournament)
	end
end