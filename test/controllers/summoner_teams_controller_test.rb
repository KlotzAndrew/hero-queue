require 'test_helper'

class SummonerTeamsControllerTest < ActionController::TestCase
	def setup
		@admin = users(:grok)
		@other_user = users(:thrall)
		@tournament_with_teams = tournaments(:tournament_with_teams)
		@team = @tournament_with_teams.teams.first
	end

	test "should get index" do
		log_in_as(@admin)
		get :index, :tournament_id => @tournament_with_teams.id, :team_id => @team
		
		assert_response :success
		assert_equal @team.summoners.count, assigns(:summoner_teams).count
		assert_template partial: '_team_assignment', count: @team.summoners.count
		assert assigns(:ringer)
	end

	test "should redirect index when not admin" do
		get :index, :tournament_id => @tournament_with_teams.id, :team_id => @team
		assert_redirected_to login_url
	end

	test "should redirect index when not logged in" do
		log_in_as(@other_user)
		get :index, :tournament_id => @tournament_with_teams.id, :team_id => @team
		assert_redirected_to root_url
	end

	test "should update summoner as absent or present" do
		log_in_as(@admin)
		summoner = @team.summoners.first
		assert_difference '@team.summoners.count', -1 do
      patch :update, id: summoner.summoner_teams.first,
      	summoner_team: 
	      	{ 
		        absent: true
	        }
    end
    assert_difference '@team.summoners.count', 1 do
      patch :update, id: summoner.summoner_teams.first,
      	summoner_team: 
	      	{ 
		        absent: false
	        }
    end
	end

	test "update should redirect unless logged in" do
		summoner = @team.summoners.first
		assert_difference '@team.summoners.count', 0 do
      patch :update, id: summoner.summoner_teams.first,
      	summoner_team: 
	      	{ 
		        absent: true
	        }
    end
    assert_redirected_to login_url
  end

  test "update should redirect unless admin" do
		log_in_as(@other_user)
		summoner = @team.summoners.first
		assert_difference '@team.summoners.count', 0 do
      patch :update, id: summoner.summoner_teams.first,
      	summoner_team: 
	      	{ 
		        absent: true
	        }
    end
    assert_redirected_to root_url
  end

  test "create should add in a ringer" do
  	@team.summoners.last.summoner_teams.first.update(absent: true)
  	log_in_as(@admin)
  	assert_difference '@team.summoners.count', 1 do
	  	post :create, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
	      	summoner_team: 
		      	{ 
			        summonerName: "boxstripe"
		        }
  	end
  	assert_redirected_to tournament_team_summoner_teams_path(@tournament_with_teams, @team)
  end

  test "should redirect create unless logged in" do
  	@team.summoners.last.summoner_teams.first.update(absent: true)
  	assert_difference '@team.summoners.count', 0 do
	  	post :create, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
	      	summoner_team: 
		      	{ 
			        summonerName: "boxstripe"
		        }
  	end
  	assert_redirected_to login_url
	end

	test "should redirect create unless user" do
		@team.summoners.last.summoner_teams.first.update(absent: true)
		log_in_as(@other_user)
  	assert_difference '@team.summoners.count', 0 do
	  	post :create, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
	      	summoner_team: 
		      	{ 
			        summonerName: "boxstripe"
		        }
  	end
  	assert_redirected_to root_url
	end
end
