require 'test_helper'

class SeriesParticipationsControllerTest < ActionController::TestCase
  setup do
    @series = series(:winter)
  end

  test "should get index" do
    get :index, :series_id => @series.id
    assert_response :success
    assert_not_nil assigns(:series_participations)
  end
end
