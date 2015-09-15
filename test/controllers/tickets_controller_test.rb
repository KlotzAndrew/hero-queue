require 'test_helper'

class TicketsControllerTest < ActionController::TestCase
  setup do
    # @ticket = tickets(:one)
    @tournament = tournaments(:tournament_unsold)
  end

  test "should create ticket" do
    assert_difference 'Ticket.count', 1 do
      post :create, ticket: { tournament_id: @tournament.id, summonerName: "Boxstripe" }
    end

    ticket = assigns(:ticket)
    assert_redirected_to tournament_path(@tournament, :active_ticket => ticket)
  end

  test "shoudl create ticket via ajax" do
    assert_difference('Ticket.count', 1) do
      xhr :post, :create, ticket: { tournament_id: @tournament.id, summonerName: "Boxstripe" }
    end

    assert_response :success
    assert_select_jquery :html, '#register' do
      assert_select 'div#active_ticket'
    end
  end

end
