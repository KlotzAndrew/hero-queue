require 'test_helper'

class SummonerTest < ActiveSupport::TestCase
	def setup
    stub_request(:get, 'https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/timeout?api_key=' + Rails.application.secrets.league_api_key).to_timeout
    @summoner = summoners(:boxstripe)
    @other_summoner = summoners(:hukkk)
 	end

  test "should not return unpaid ticket associations" do
    ticket = @summoner.tickets.new(
      tournament_id: 1,
      status: "")
    assert ticket.save
    assert_not @summoner.tickets.include?(ticket)
  end

  test "should return paid ticket associations" do
    ticket = @summoner.tickets.new(
      tournament_id: 1,
      status: "Completed")
    assert ticket.save
    assert @summoner.tickets.include?(ticket)
  end

  test "api call responds to throttle limit" do
    name_summoner = "theoddone"
    VCR.use_cassette("lol_summoners") do
      assert_difference('Summoner.all.count', 0) do
  	    summoner = Summoner.find_or_create(name_summoner, "summoner name", 0)
  	    assert_equal :league_servers, summoner.errors.messages.first.first
      end
    end
  end

  test "api call responds to summoner 404" do
    name_summoner = "4"
    VCR.use_cassette("lol_summoners") do
      assert_difference('Summoner.all.count', 0) do
  	    summoner = Summoner.find_or_create(name_summoner)
  	    assert_equal :cant_find, summoner.errors.messages.first.first
      end
    end
  end

  test "api call responds to invalid name" do
    name_summoner = ""
    VCR.use_cassette("lol_summoners") do
      assert_difference('Summoner.all.count', 0) do
        summoner = Summoner.find_or_create(name_summoner)
        assert_equal :invalid_name, summoner.errors.messages.first.first
      end
    end
  end

  test "api call responds to timeout" do
    name_summoner = "timeout"
    assert_difference('Summoner.all.count', 0) do
	    summoner = Summoner.find_or_create(name_summoner)
	    assert_equal :timeout, summoner.errors.messages.first.first
    end
  end
end
