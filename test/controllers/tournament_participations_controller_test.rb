require 'test_helper'

class TournamentParticipationsControllerTest < ActionController::TestCase
	def setup
		@admin = users(:grok)
		@user = users(:thrall)
		@tournament_with_teams = tournaments(:tournament_with_teams)
		@team = @tournament_with_teams.teams.first
	end

	test "should get index with tournament participations" do
		log_in_as(@admin)
		get :index, :tournament_id => @tournament_with_teams.id, :team_id => @team
		assert_response :success
		assert_equal @team.summoners.count, assigns(:tournament_participations).count
		assert_template partial: '_team_assignment', count: @team.summoners.count
		assert assigns(:ringer)
	end

	test "should redirect index when not admin" do
		get :index, :tournament_id => @tournament_with_teams.id, :team_id => @team
		assert_redirected_to login_url
	end

	test "should redirect index when not logged in" do
		log_in_as(@user)
		get :index, :tournament_id => @tournament_with_teams.id, :team_id => @team
		assert_redirected_to root_url
	end

	test "should update summoner as absent or present" do
		log_in_as(@admin)
		summoner = @team.summoners.first
		assert_difference '@team.summoners.count', -1 do
      patch :update, 
	      tournament_id: @tournament_with_teams,
      	team_id: @team,
      	id: summoner.tournament_participations.first,
      	tournament_participation: 
	      	{ 
		        absent: true
	        }
    end
    assert_difference '@team.summoners.count', 1 do
      patch :update, 
      tournament_id: @tournament_with_teams,
    	team_id: @team,
      id: summoner.tournament_participations.first,
      	tournament_participation: 
	      	{ 
		        absent: false
	        }
    end
	end

	test "update should update team_id if nil" do
		log_in_as(@admin)
		summoner = @team.summoners.first
		tournament_participation = summoner.tournament_participations.first
		tournament_participation.update(team_id: nil)
		assert_equal nil, tournament_participation.team_id
		patch :update, 
	      tournament_id: @tournament_with_teams,
      	team_id: @team,
      	id: tournament_participation.id,
      	tournament_participation: 
	      	{ 
		        team_id: @team.id
	        }
	  assert_equal @team.id, tournament_participation.reload.team_id
	end

	test "update should not change team_id if already assigned" do
		log_in_as(@admin)
		summoner = @team.summoners.first
		tournament_participation = summoner.tournament_participations.first
		patch :update, 
	      tournament_id: @tournament_with_teams,
      	team_id: @team,
      	id: tournament_participation.id,
      	tournament_participation: 
	      	{ 
		        team_id: @team.id + 1
	        }
	  assert_equal @team.id, tournament_participation.reload.team_id
	end

	test "update should redirect unless logged in" do
		summoner = @team.summoners.first
		assert_difference '@team.summoners.count', 0 do
      patch :update, 
      	tournament_id: @tournament_with_teams,
      	team_id: @team,
      	id: summoner.tournament_participations.first,
      	tournament_participation: 
	      	{ 
		        absent: true
	        }
    end
    assert_redirected_to login_url
  end

  test "update should redirect unless admin" do
		log_in_as(@user)
		summoner = @team.summoners.first
		assert_difference '@team.summoners.count', 0 do
      patch :update, 
      	tournament_id: @tournament_with_teams,
      	team_id: @team,
	      id: summoner.tournament_participations.first,
      	tournament_participation: 
	      	{ 
		        absent: true
	        }
    end
    assert_redirected_to root_url
  end

  test "create should add in a ringer" do
  	@team.summoners.last.tournament_participations.first.update(absent: true)
  	log_in_as(@admin)
  	assert_difference '@team.summoners.count', 1 do
	  	post :create, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
	      	tournament_participation: 
		      	{ 
			        summonerName: "boxstripe"
		        }
  	end
  	assert_redirected_to tournament_team_tournament_participations_path(@tournament_with_teams, @team)
  end

	test "delete should remove ringer from tournament" do
		tournament_participation = @team.tournament_participations.last
		ticket = tournament_participation.ticket
		log_in_as(@admin)

		tournament_participation.update(status: "Ringer")
  	assert_difference '@team.summoners.count', -1 do
	  	delete :destroy, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
      	id: tournament_participation
  	end
  	assert_equal 0, Ticket.where(id: ticket.id).count
  	assert_redirected_to tournament_team_tournament_participations_path(@tournament_with_teams, @team)
	end  

	test "delete should not remove participants who paid" do
		tournament_participation = @team.tournament_participations.last
		ticket = tournament_participation.ticket
		log_in_as(@admin)
		#paid ticket cannot be deleted
		assert_difference '@team.summoners.count', 0 do
	  	delete :destroy, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
      	id: tournament_participation
  	end
  	assert_equal 1, Ticket.where(id: ticket.id).count
  	assert_redirected_to tournament_team_tournament_participations_path(@tournament_with_teams, @team)
	end

  test "should redirect create unless logged in" do
  	@team.summoners.last.tournament_participations.first.update(absent: true)
  	assert_difference '@team.summoners.count', 0 do
	  	post :create, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
	      	tournament_participation: 
		      	{ 
			        summonerName: "boxstripe"
		        }
  	end
  	assert_redirected_to login_url
	end

	test "should redirect create unless user" do
		@team.summoners.last.tournament_participations.first.update(absent: true)
		log_in_as(@user)
  	assert_difference '@team.summoners.count', 0 do
	  	post :create, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
	      	tournament_participation: 
		      	{ 
			        summonerName: "boxstripe"
		        }
  	end
  	assert_redirected_to root_url
	end

	test "should redirect delete if not admin in" do
		tournament_participation = @team.tournament_participations.last
		ticket = tournament_participation.team.tournament.tickets.where(summoner_id: tournament_participation.summoner_id).first
		log_in_as(@user)
		#paid ticket cannot be deleted
		assert_difference '@team.summoners.count', 0 do
	  	delete :destroy, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
      	id: tournament_participation
  	end
  	assert_equal 1, Ticket.where(id: ticket.id).count
  	assert_redirected_to root_url
	end

	test "should redirect delete if not logged in" do
		tournament_participation = @team.tournament_participations.last
		ticket = tournament_participation.team.tournament.tickets.where(summoner_id: tournament_participation.summoner_id).first
		#paid ticket cannot be deleted
		assert_difference '@team.summoners.count', 0 do
	  	delete :destroy, 
	  		tournament_id: @tournament_with_teams.id, 
	  		team_id: @team.id, 
      	id: tournament_participation
  	end
  	assert_equal 1, Ticket.where(id: ticket.id).count
  	assert_redirected_to login_url
	end
end
