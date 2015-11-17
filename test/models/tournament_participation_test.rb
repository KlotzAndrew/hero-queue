require 'test_helper'

class TournamentParticipationTest < ActiveSupport::TestCase
	def setup
    @tournament_participation = TournamentParticipation.new(
    	summoner_id: 1,
    	tournament_id: 1,
    	ticket_id: 1,
    	team_id: nil, 
    	duo_id: nil,
    	duo_approved: false)

		@tournament_with_teams = tournaments(:tournament_with_teams)
		@team = @tournament_with_teams.teams.first
		@summoner = summoners(:boxstripe)
	end

	test "should be valid" do
		assert @tournament_participation.valid?
	end

	test "summoner_id should be present" do
		@tournament_participation.summoner_id = nil
		assert_not @tournament_participation.valid?
	end

	test "tournament_id should be present" do
		@tournament_participation.tournament_id = nil
		assert_not @tournament_participation.valid?
	end

	test "ticket_id should be present" do
		@tournament_participation.ticket_id = nil
		assert_not @tournament_participation.valid?
	end

	test "correctly adds ringer" do
		@team.summoners.first.tournament_participations.first.update(absent: true)
		VCR.use_cassette("mixed_requests") do
			assert_not @team.summoners.include?(@summoner)
			assert_difference '@team.summoners.count', 1 do
				TournamentParticipation.add_to_team_as_ringer(@summoner.summonerName, @tournament_with_teams.id, @team.id)
			end
			assert @team.summoners.include?(@summoner)
			assert_equal "Ringer", @summoner.tickets.last.status
		end
	end
end
