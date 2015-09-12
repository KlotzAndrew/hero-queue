require 'test_helper'

class SummonerTest < ActiveSupport::TestCase

	def setup
		stub_request(:get, 'https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/theoddone?api_key=' + Rails.application.secrets.league_api_key).
		    to_return(status: 200, body: '{"theoddone":{"id":60783,"name":"TheOddOne","profileIconId":752,"summonerLevel":30,"revisionDate":1437870268000}}', 
		    headers: {})
   	end

  test "summoner triggers api throttle error" do
    name_summoner = "theoddone"
    assert_difference('Summoner.all.count', 0) do
	    summoner = Summoner.find_or_create(name_summoner, 0)
	    assert_equal :league_servers, summoner.errors.messages.first.first
    end
  end
end
