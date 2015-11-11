require 'test_helper'

class ReplaceSummonerWithRingerTest < ActionDispatch::IntegrationTest
	def setup
		@tournament_with_teams = tournaments(:tournament_with_teams)
		@admin = users(:grok)
	end

	test "mark absent and replace with ringer" do
		team = @tournament_with_teams.teams.first
		summoner = team.summoners.first
		log_in_as(@admin)
		#mark summoner as absent
		get tournament_team_summoner_teams_path(@tournament_with_teams, team)
		assert_template 'summoner_teams/index'
		assert_difference 'team.summoners.count', -1 do
      patch summoner_team_path(summoner.summoner_teams.first), 
      	summoner_team: 
	      	{ 
		        absent: true
	        }
    end
    follow_redirect!
    assert_template 'summoner_teams/index'
    #replaces summoner with ringer
    assert_difference 'team.summoners.count', 1 do
      post tournament_team_summoner_teams_path(@tournament_with_teams, team), 
      	summoner_team: 
	      	{ 
		        summonerName: "boxstripe"
	        }
    end
    follow_redirect!
    assert_template 'summoner_teams/index'
	end

	test "toggle player absent/present" do
		team = @tournament_with_teams.teams.first
		summoner = team.summoners.first
		log_in_as(@admin)
		#mark summoner as absent
		get tournament_team_summoner_teams_path(@tournament_with_teams, team)
		assert_template 'summoner_teams/index'
		assert_difference 'team.summoners.count', -1 do
      patch summoner_team_path(summoner.summoner_teams.first), 
      	summoner_team: 
	      	{ 
		        absent: true
	        }
    end
    follow_redirect!
    assert_template 'summoner_teams/index'
    #mark summoner as present
    assert_difference 'team.summoners.count', 1 do
      patch summoner_team_path(summoner.summoner_teams.first), 
      	summoner_team: 
	      	{ 
		        absent: false
	        }
    end
    follow_redirect!
    assert_template 'summoner_teams/index'
	end
end