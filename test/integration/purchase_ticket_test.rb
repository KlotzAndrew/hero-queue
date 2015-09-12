require 'test_helper'
require "minitest/mock"

class PurchaseTicketTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = tournaments(:sq_one)
    @summoner = summoners(:boxstripe)
    @duo = summoners(:hukkk)
  end

  test "register with existing summoner and duo" do
  	get tournaments_path(@tournament)
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
  	Summoner.stub(:summonerName).any_instance().returns("War and Peace")
  	summoner = Summoner.new
  	assert_equal summoner.summonerName, "yuppp"
  end
end
