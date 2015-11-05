require 'test_helper'

class TicketsControllerTest < ActionController::TestCase
  setup do
    @tournament = tournaments(:tournament_unsold)
    @ticket = tickets(:unpaid)
  end

  test "should create ticket" do
    assert_difference 'Ticket.count', 1 do
      post :create, ticket: { 
        tournament_id: @tournament.id, 
        summonerName: "Boxstripe" }
    end

    ticket = assigns(:ticket)
    assert_redirected_to tournament_path(@tournament, :active_ticket => ticket)
  end

  test "should create ticket via ajax" do
    assert_difference('Ticket.count', 1) do
      xhr :post, :create, ticket: { 
        tournament_id: @tournament.id, 
        summonerName: "Boxstripe" }
    end

    assert_response :success
    assert_select_jquery :html, '#register' do
      assert_select 'div#active_ticket'
    end
  end

  test "hook should correctly updates completed ticket" do
    VCR.use_cassette("paypal_api") do
      post :hook, {
        payment_status: "Completed",
        invoice: @ticket.id
      }
      assert_equal "Completed", @ticket.reload.status
    end
  end

  test "hook should correctly updates pending ticket" do
    VCR.use_cassette("paypal_api") do
      post :hook, {
        payment_status: "Pending",
        invoice: @ticket.id
      }
      assert_equal "Pending", @ticket.reload.status
    end
  end

end
