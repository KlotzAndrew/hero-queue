require 'test_helper'

class TournamentsControllerTest < ActionController::TestCase
  setup do
    @tournament = tournaments(:tournament_unsold)
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
end
