require 'test_helper'

class TournamentsControllerTest < ActionController::TestCase
  def setup
    @tournament_sold = tournaments(:tournament_sold)
    @user = users(:grok)
    @other_user = users(:thrall)
  end

  def reset_summoner_elos(tournament)
    tournament.all_solos.each do |x|
      x.first.update(elo: nil)
    end
    tournament.all_duos.each do |x, y|
      x.update(elo: nil)
      y.update(elo: nil)
    end
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

  test "only admin can update summoners elo" do
    # patch :update_summoners_elo 
  end

  # test "should only allow admin to edit tournament" do
  #   patch :update, id: @tournament, tournament: {}
  #   assert_redirected_to login_url
  #   log_in_as(@other_user)
  #   assert_not @other_user.admin?
  #   patch :update, id: @tournament, tournament: {}
  #   assert_redirected_to root_url
  # end
end
