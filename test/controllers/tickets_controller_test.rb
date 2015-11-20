require 'test_helper'

class TicketsControllerTest < ActionController::TestCase
  setup do
    @tournament = tournaments(:tournament_unsold)
    @ticket = tickets(:unpaid)
    @admin = users(:grok)
    @user = users(:thrall)
    @refund_ticket = tickets(:boxstripe_ticket_sold)
  end

  test "should create ticket without tournament participation" do
    assert_difference 'Ticket.count', 1 do
      post :create, ticket: { 
        tournament_id: @tournament.id, 
        summonerName: "Boxstripe" }
    end

    assert_empty @ticket.tournament_participations
    ticket = assigns(:ticket)
    assert_redirected_to tournament_path(@tournament, :active_ticket => ticket)
  end

  test "should create ticket via ajax without tournament participation" do
    assert_difference('Ticket.count', 1) do
      xhr :post, :create, ticket: { 
        tournament_id: @tournament.id, 
        summonerName: "Boxstripe" }
    end

    assert_empty @ticket.tournament_participations
    assert_response :success
    assert_select_jquery :html, '#register' do
      assert_select 'div#active_ticket'
    end
  end

  test "hook should update completed ticket & create tournament_participation" do
    VCR.use_cassette("paypal_api") do
      post :hook, {
        payment_status: "Completed",
        invoice: @ticket.id
      }
      assert_equal "Completed", @ticket.reload.status
      assert_equal @ticket.tournament_id, @ticket.tournament_participations.first.tournament_id
    end
  end

  test "hook should update pending ticket & create tournament_participation" do
    VCR.use_cassette("paypal_api") do
      post :hook, {
        payment_status: "Pending",
        invoice: @ticket.id
      }
      assert_equal "Pending", @ticket.reload.status
      assert_equal @ticket.tournament_id, @ticket.tournament_participations.first.tournament_id
    end
  end

  test "update should mark ticket as refunded for admin" do
    log_in_as(@admin)
    tournament = @refund_ticket.tournament
    patch :update, 
      id: @refund_ticket.id, 
      ticket: {
        status: "Refunded"
    }
    assert_equal 0, @refund_ticket.tournament_participations.count
    assert_equal "Refunded", @refund_ticket.reload.status
    assert_redirected_to tournament_teams_path(tournament)
  end

  test "update can only be triggered by admin" do
    tournament = @refund_ticket.tournament
    log_in_as(@user)
    patch :update, 
      id: @refund_ticket.id, 
      ticket: {
        status: "Refunded"
    }
    assert_equal 1, @refund_ticket.tournament_participations.count
    assert_equal "Completed", @refund_ticket.reload.status
    assert_redirected_to root_url
  end

  test "update can only be triggered when logged in" do
    tournament = @refund_ticket.tournament
    patch :update, 
      id: @refund_ticket.id, 
      ticket: {
        status: "Refunded"
    }
    assert_equal 1, @refund_ticket.tournament_participations.count
    assert_equal "Completed", @refund_ticket.reload.status
    assert_redirected_to login_url
  end
end
