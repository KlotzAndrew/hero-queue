require 'test_helper'

class TicketsControllerTest < ActionController::TestCase
  setup do
    # @ticket = tickets(:one)
    @tournament = tournaments(:sq_one)
  end

  test "should create ticket" do
    assert_difference('Ticket.count') do
      post :create, ticket: { tournament_id: @tournament.id, summonerName: "Boxstripe"  }
    end

    assert_redirected_to tournaments_path(@tournament)
  end

end
