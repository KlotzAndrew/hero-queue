require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  def setup
    @tournament = tournaments(:tournament_sold)
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
    build_demo_teams(@tournament)
    get :index, :tournament_id => @tournament.id
    assert_template partial: '_team', count: 0
  end

  test "should not display unapproved teams to admin" do
    build_demo_teams(@tournament)
    log_in_as(@user)
    assert @user.admin?
    get :index, :tournament_id => @tournament.id
    assert_template partial: '_team', count: 0
  end

  test "should display teams when approved" do
    build_demo_teams(@tournament)
    @tournament.update(teams_approved: true)
    get :index, :tournament_id => @tournament.id
    assert_template partial: '_team', count: 2
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
end