require 'test_helper'

class TeamsBuilderTest < ActionDispatch::IntegrationTest
	def setup
		@tournament_sold = tournaments(:tournament_sold)
		@user = users(:grok)
    @other_user = users(:thrall)
	end

	test "admin should build teams for full roster" do
		VCR.use_cassette("lolking_nokogiri") do
			log_in_as(@user)
			assert @user.admin?
			assert_empty @tournament_sold.teams
			patch tournament_path(@tournament_sold), options: "buildteams"
			assert_equal @tournament_sold.reload.teams.count, 8
		end
	end
end
