require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  def setup
    @tournament = tournaments(:tournament_unsold)
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

  test "should not display tickets for admin on index" do
  	get :index, :tournament_id => @tournament.id
  	assert_not assigns(:tickets)
  	log_in_as(@other_user)
  	assert_not @other_user.admin?
  	get :index, :tournament_id => @tournament.id
  	assert_not assigns(:tickets)
  end
end
