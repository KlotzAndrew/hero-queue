require 'test_helper'

class PurchaseTicketTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = tournaments(:tournament_unsold)
    @tournament_sold = tournaments(:tournament_sold)
    @tournament_oneseat = tournaments(:tournament_oneseat)
    @summoner = summoners(:boxstripe)
    @duo = summoners(:hukkk)

  end

  test "solo needs 1 seat" do
    get tournament_path(@tournament_sold)
    assert_difference '@summoner.tickets.count', 0 do
      xhr :post, tickets_path, ticket: { 
        summonerName: @summoner.summonerName,
        tournament_id: @tournament_sold.id }
    end
    ticket = assigns(:ticket)
    assert_equal ticket.errors.first, [:sold_out, ", sorry there are no tickets left!"]
  end

  test "duo needs 2 seats" do
    get tournament_path(@tournament_oneseat)
    assert_difference '@summoner.tickets.count', 0 do
      xhr :post, tickets_path, ticket: { 
        summonerName: @summoner.summonerName,
        duoName: @duo.summonerName,
        tournament_id: @tournament_oneseat.id }
    end
     ticket = assigns(:ticket)
      assert_equal ticket.errors.first, [:only_one, "seat left! Unable to register a duo"]
  end

  test "register with existing summoner and duo" do
  	get tournament_path(@tournament)
  	assert_difference '@summoner.tickets.count', 1 do
  		xhr :post, tickets_path, ticket: { 
  			summonerName: @summoner.summonerName,
  			duoName: @duo.summonerName,
  			tournament_id: @tournament.id }
  	end
  	ticket = assigns(:ticket)
  	assert_equal ticket.summoner, @summoner
  	assert_equal ticket.duo, @duo
  	assert_select_jquery :html, '#register' do
      assert_select 'div#active_ticket'
    end
  end

  test "register with new summoner and duo" do
    name_summoner = "theoddone"
    name_duo = "Annie Bot"

    VCR.use_cassette("lol_summoners") do
    	get tournament_path(@tournament)
    	assert_difference 'Ticket.count', 1 do
    		xhr :post, tickets_path, ticket: { 
    			summonerName: name_summoner,
    			duoName: name_duo,
    			tournament_id: @tournament.id }
    	end
      ticket = assigns(:ticket)
      assert_equal ticket.summoner.summonerName, name_summoner
      assert_equal ticket.duo.summonerName, name_duo
      assert_select_jquery :html, '#register' do
        assert_select 'div#active_ticket'
      end
    end
  end

  test "shows error with invalid summoner information" do
    name_invald = "4"

    VCR.use_cassette("lol_summoners") do
      assert_difference('Ticket.count', 0) do
        xhr :post, tickets_path, ticket: { 
          summonerName: name_invald,
          tournament_id: @tournament.id }
      end
      ticket = assigns(:ticket)
      assert_equal ticket.errors.first, [:summoner_id, "can't be blank"]

      assert_difference '@summoner.tickets.count', 1 do
        xhr :post, tickets_path, ticket: { 
          summonerName: @summoner.summonerName,
          duoName: @duo.summonerName,
          tournament_id: @tournament.id }
      end
      ticket = assigns(:ticket)
      assert_equal ticket.summoner, @summoner
      assert_equal ticket.duo, @duo
      assert_select_jquery :html, '#register' do
        assert_select 'div#active_ticket'
      end
    end
  end
end
