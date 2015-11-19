require 'test_helper'

class SeriesParticipationsControllerTest < ActionController::TestCase
  setup do
    @series_participation = series_participations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:series_participations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create series_participation" do
    assert_difference('SeriesParticipation.count') do
      post :create, series_participation: {  }
    end

    assert_redirected_to series_participation_path(assigns(:series_participation))
  end

  test "should show series_participation" do
    get :show, id: @series_participation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @series_participation
    assert_response :success
  end

  test "should update series_participation" do
    patch :update, id: @series_participation, series_participation: {  }
    assert_redirected_to series_participation_path(assigns(:series_participation))
  end

  test "should destroy series_participation" do
    assert_difference('SeriesParticipation.count', -1) do
      delete :destroy, id: @series_participation
    end

    assert_redirected_to series_participations_path
  end
end
