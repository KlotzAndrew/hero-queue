require 'test_helper'

class SummonerTeamTest < ActiveSupport::TestCase
	def setup
		@tournament_with_teams = tournaments(:tournament_with_teams)
		@team = @tournament_with_teams.teams.first
		@summoner = summoners(:boxstripe)
	end

	test "correctly adds ringer" do
		@team.summoners.first.summoner_teams.first.update(absent: true)
		VCR.use_cassette("mixed_requests") do
			summoner_team = SummonerTeam.new
			assert_not @team.summoners.include?(@summoner)
			assert_difference '@team.summoners.count', 1 do
				summoner_team.add_to_team_as_ringer(@summoner.summonerName, @tournament_with_teams.id, @team.id)
			end
			assert @team.summoners.include?(@summoner)
			assert_equal "Ringer", @summoner.tickets.last.status
		end
	end
end
