require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  setup do
    # @team = teams(:one)
    @tournament = tournaments(:sq_one)
  end

  test "should get index" do
    get :index, :tournament_id => @tournament.id
    assert_response :success
  end
end
