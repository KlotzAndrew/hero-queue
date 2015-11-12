require 'test_helper'

class PurchaseTicketTest < ActionDispatch::IntegrationTest
  def setup
    @tournament = tournaments(:tournament_unsold)
    @tournament_sold = tournaments(:tournament_sold)
    @summoner = summoners(:boxstripe)
    @duo = summoners(:hukkk)
  end

  test "should not create ticket if teams approved" do
    @tournament_sold.increment!(:total_players)
    @tournament_sold.update(teams_approved: true)
    get tournament_path(@tournament_sold)
    assert_difference 'Ticket.count', 0 do
      xhr :post, tickets_path, ticket: { 
        summonerName: @summoner.summonerName,
        tournament_id: @tournament_sold.id }
    end

    ticket = assigns(:ticket)
    assert_equal ticket.errors.first, [:too_late, ", sorry teams have already been built!"]
  end

  test "should return error when no seats for solo" do
    get tournament_path(@tournament_sold)
    assert_difference 'Ticket.count', 0 do
      xhr :post, tickets_path, ticket: { 
        summonerName: @summoner.summonerName,
        tournament_id: @tournament_sold.id }
    end

    ticket = assigns(:ticket)
    assert_equal ticket.errors.first, [:sold_out, ", sorry there are no tickets left!"]
  end

  test "should return error when no seats for duo" do
    @tournament_sold.increment!(:total_players)
    get tournament_path(@tournament_sold)
    assert_difference 'Ticket.count', 0 do
      xhr :post, tickets_path, ticket: { 
        summonerName: @summoner.summonerName,
        duoName: @duo.summonerName,
        tournament_id: @tournament_sold.id }
    end

    ticket = assigns(:ticket)
    assert_equal ticket.errors.first, [:only_one, "seat left! Unable to register a duo"]
  end

  test "register with existing summoner and duo" do
  	get tournament_path(@tournament)
  	assert_difference 'Ticket.count', 1 do
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
      assert_select 'form[action=?]', "https://www.paypal.com/cgi-bin/webscr"
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
        assert_select 'form[action=?]', "https://www.paypal.com/cgi-bin/webscr"
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

      assert_difference 'Ticket.count', 1 do
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
        assert_select 'form[action=?]', "https://www.paypal.com/cgi-bin/webscr"
      end
    end
  end
end
