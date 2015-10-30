require 'test_helper'

class TournamentsControllerTest < ActionController::TestCase
  def setup
    @tournament_sold = tournaments(:tournament_sold)
    @user = users(:grok)
    @other_user = users(:thrall)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:upcoming)
  end

  test "should show tournament" do
    get :show, id: @tournament_sold
    assert_response :success
    assert_not_nil assigns(:ticket)
  end

  test "should let admin update summoners elo" do
    @tournament_sold.all_solos.first.first.update(elo: nil)
    log_in_as(@user)
    assert @user.admin?
    VCR.use_cassette("lolking_nokogiri") do
      patch :update_summoners_elo, id: @tournament_sold
    end
    assert_not_nil @tournament_sold.all_solos.first.first.reload.elo
    assert_redirected_to tournament_teams_path(@tournament_sold)
  end

  test "should be logged in to update summoners elo" do
    patch :update_summoners_elo, id: @tournament_sold
    assert_redirected_to login_url
  end

  test "should be admin to update summoners elo" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch :update_summoners_elo, id: @tournament_sold
    assert_redirected_to root_url
  end

  test "should let admin build teams" do
    log_in_as(@user)
    assert @user.admin?
    patch :create_tournament_teams, id: @tournament_sold
    assert_equal @tournament_sold.reload.teams.count, @tournament_sold.total_teams
    assert_redirected_to tournament_teams_path(@tournament_sold)
  end

  test "should be admin to build teams" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch :create_tournament_teams, id: @tournament_sold
    assert_redirected_to root_url
  end

  test "should be logged in to build teams" do
    patch :create_tournament_teams, id: @tournament_sold
    assert_redirected_to login_url
  end

end
