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
  	assert assigns(:tickets)
  end

  test "should not display tickets for non-admin on index" do
  	get :index, :tournament_id => @tournament.id
  	assert_not assigns(:tickets)
  	log_in_as(@other_user)
  	assert_not @other_user.admin?
  	get :index, :tournament_id => @tournament.id
  	assert_not assigns(:tickets)
  end

  test "should not display teams unless approved" do
    build_demo_teams(@tournament)
    get :index, :tournament_id => @tournament.id
    assert_empty assigns(:teams)
  end

  test "should display unapproved teams to admin" do
    build_demo_teams(@tournament)
    log_in_as(@user)
    assert @user.admin?
    get :index, :tournament_id => @tournament.id
    assert_operator assigns(:teams).count, :>, 0
  end

  test "should display teams when approved" do
    build_demo_teams(@tournament)
    @tournament.update(teams_approved: true)
    get :index, :tournament_id => @tournament.id
    assert_operator assigns(:teams).count, :>, 0
  end
end
