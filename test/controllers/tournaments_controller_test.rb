require 'test_helper'

class TournamentsControllerTest < ActionController::TestCase
  setup do
    @tournament = tournaments(:tournament_unsold)
    @user = users(:grok)
    @other_user = users(:thrall)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:upcoming)
  end

  test "should show tournament" do
    get :show, id: @tournament
    assert_response :success
    assert_not_nil assigns(:ticket)
  end

  test "should only allow admin to edit tournament" do
    patch :update, id: @tournament, tournament: {}
    assert_redirected_to login_url
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch :update, id: @tournament, tournament: {}
    assert_redirected_to root_url
  end
end
