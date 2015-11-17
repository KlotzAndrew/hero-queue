require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  def setup
    @tournament = tournaments(:tournament_sold)
    @tournament_with_teams = tournaments(:tournament_with_teams)
    @team = @tournament_with_teams.teams.first
    @user = users(:grok)
    @other_user = users(:thrall)
  end

  test "should get index" do
    get :index, :tournament_id => @tournament.id
    assert_response :success
  end

  test "should display tickets for admin on index" do
  	log_in_as(@user)
  	get :index, :tournament_id => @tournament.id
  	assert_template partial: '_ticket', count: 7
  end

  test "should not display tickets for non-admin on index" do
  	get :index, :tournament_id => @tournament.id
  	assert_template partial: '_ticket', count: 0
  	log_in_as(@other_user)
  	assert_not @other_user.admin?
  	get :index, :tournament_id => @tournament.id
  	assert_template partial: '_ticket', count: 0
  end

  test "should not display teams unless approved" do
    @tournament_with_teams.update(teams_approved: false)
    get :index, :tournament_id => @tournament_with_teams.id
    assert_template partial: '_team', count: 0
  end

  test "should not display unapproved teams to admin" do
    @tournament_with_teams.update(teams_approved: false)
    log_in_as(@user)
    assert @user.admin?
    get :index, :tournament_id => @tournament_with_teams.id
    assert_template partial: '_team', count: 0
  end

  test "should display teams when approved" do
    @tournament.update(teams_approved: true)
    get :index, :tournament_id => @tournament_with_teams.id
    assert_template partial: '_team', count: 3
  end

  test "should display team stats to admin" do
    log_in_as(@user)
    get :index, :tournament_id => @tournament.id
    assert_not_nil assigns(:team_stats)
  end

  test "should not display team stats to non-admin" do
    get :index, :tournament_id => @tournament.id
    assert_nil assigns(:team_stats)
    log_in_as(@other_user)
    get :index, :tournament_id => @tournament.id
    assert_nil assigns(:team_stats)
  end

  test "should update team position for admin" do
    log_in_as(@user)
    patch :update, 
      tournament_id: @tournament_with_teams.id,
      id: @team.id,
      team: {
        position: 1
      }
    assert_equal 1, @team.reload.position
    assert_redirected_to tournament_teams_path(@tournament_with_teams)
  end

  test "should redirect update if not admin" do
    log_in_as(@other_user)
    patch :update, 
      tournament_id: @tournament_with_teams.id,
      id: @team.id,
      team: {
        position: 1
      }
    assert_equal nil, @team.reload.position
    assert_redirected_to root_url
  end
end