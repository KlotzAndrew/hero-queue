require 'test_helper'

class PurchaseTicketTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = tournaments(:tournament_unsold)
    @tournament_sold = tournaments(:tournament_sold)
    @tournament_oneseat = tournaments(:tournament_oneseat)
    @summoner = summoners(:boxstripe)
    @duo = summoners(:hukkk)

    stub_request(:get, 'https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/theoddone?api_key=' + Rails.application.secrets.league_api_key).
    to_return(status: 200, body: '{"theoddone":{"id":60783,"name":"TheOddOne","profileIconId":752,"summonerLevel":30,"revisionDate":1437870268000}}', 
    headers: {})

    stub_request(:get, 'https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/anniebot?api_key=' + Rails.application.secrets.league_api_key).
    to_return(status: 200, body: '{"anniebot":{"id":35590582,"name":"Annie Bot","profileIconId":7,"summonerLevel":30,"revisionDate":1442062990000}}', 
    headers: {})

    stub_request(:get, 'https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/make_an_error_plz?api_key=' + Rails.application.secrets.league_api_key).
    to_return(status: 404, 
    headers: {})
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

  test "shows error with invalid summoner information" do
    name_invald = "make_an_error_plz"

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
