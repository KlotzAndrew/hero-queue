require 'test_helper'

class ReplaceSummonerWithRingerTest < ActionDispatch::IntegrationTest
	def setup
		@tournament_with_teams = tournaments(:tournament_with_teams)
		@admin = users(:grok)
		@summoner = summoners(:boxstripe)
	end

	test "mark absent and replace with ringer the remove" do
		team = @tournament_with_teams.teams.first
		summoner = team.summoners.first
		log_in_as(@admin)
		#mark summoner as absent
		get tournament_team_tournament_participations_path(@tournament_with_teams, team)
		assert_template 'tournament_participations/index'
		assert_difference 'team.summoners.count', -1 do
      patch tournament_team_tournament_participation_path(@tournament_with_teams, team, summoner.tournament_participations.first), 
      	tournament_participation: 
	      	{ 
		        absent: true
	        }
    end
    follow_redirect!
    assert_template 'tournament_participations/index'
    #replaces summoner with ringer
    assert_difference 'team.summoners.count', 1 do
      post tournament_team_tournament_participations_path(@tournament_with_teams, team), 
      	tournament_participation: 
	      	{ 
		        summonerName: "boxstripe"
	        }
    end
    follow_redirect!
    assert_template 'tournament_participations/index'
	end

	# test "remove ringer from tournament" do
 #    summoner_team = team.tournament_participations.last
 #    assert_difference 'team.summoners.count', -1 do
 #      delete tournament_team_summoner_team_path(@tournament_with_teams, team, summoner_team) 
 #    end
 #    follow_redirect!
 #    assert_template 'tournament_participations/index'
	# end

	test "toggle player absent/present" do
		team = @tournament_with_teams.teams.first
		summoner = team.summoners.first
		log_in_as(@admin)
		#mark summoner as absent
		get tournament_team_tournament_participations_path(@tournament_with_teams, team)
		assert_template 'tournament_participations/index'
		assert_difference 'team.summoners.count', -1 do
      patch tournament_team_tournament_participation_path(@tournament_with_teams, team, summoner.tournament_participations.first), 
      	tournament_participation: 
	      	{ 
		        absent: true
	        }
    end
    follow_redirect!
    assert_template 'tournament_participations/index'
    #mark summoner as present
    assert_difference 'team.summoners.count', 1 do
      patch tournament_team_tournament_participation_path(@tournament_with_teams, team, summoner.tournament_participations.first), 
      	tournament_participation: 
	      	{ 
		        absent: false
	        }
    end
    follow_redirect!
    assert_template 'tournament_participations/index'
	end

	test "mark absent and replace with ticket purchase" do
		team = @tournament_with_teams.teams.first
		summoner = team.summoners.first
		log_in_as(@admin)
		#mark summoner as absent
		get tournament_team_tournament_participations_path(@tournament_with_teams, team)
		assert_template 'tournament_participations/index'
		assert_difference 'team.summoners.count', -1 do
      patch tournament_team_tournament_participation_path(@tournament_with_teams, team, summoner.tournament_participations.first), 
      	tournament_participation: 
	      	{ 
		        absent: true
	        }
    end
    follow_redirect!
    assert_template 'tournament_participations/index'
    #user purcahses ticket
    @tournament_with_teams.update(teams_approved: false)
    get tournament_path(@tournament_with_teams)
    assert_difference 'Ticket.count', 1 do
  		xhr :post, tickets_path, ticket: { 
  			summonerName: @summoner.summonerName,
  			tournament_id: @tournament_with_teams.id }
  	end
  	ticket = assigns(:ticket)
  	VCR.use_cassette('outgoing_requests') do
      post hook_path,
        payment_status: "Completed",
        invoice: ticket.id
    end
    @tournament_with_teams.update(teams_approved: true)
    #place new summoner ticket on a team
    assert_equal 1, @tournament_with_teams.unassigned_participations.count
    tournament_participation = @tournament_with_teams.unassigned_participations.first
    assert_difference 'team.summoners.count', 1 do
      patch tournament_team_tournament_participation_path(@tournament_with_teams, team, tournament_participation), 
      	tournament_participation: 
	      	{ 
		        team_id: team.id
	        }
    end
	end
end