require 'test_helper'

class TicketTest < ActiveSupport::TestCase

	def setup
		@tournament = tournaments(:tournament_unsold)

		stub_request(:get, 'https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/theoddone?api_key=' + Rails.application.secrets.league_api_key).
		to_return(status: 200, body: '{"theoddone":{"id":60783,"name":"TheOddOne","profileIconId":752,"summonerLevel":30,"revisionDate":1437870268000}}', 
		headers: {})

		stub_request(:get, 'https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/anniebot?api_key=' + Rails.application.secrets.league_api_key).
		to_return(status: 200, body: '{"anniebot":{"id":35590582,"name":"Annie Bot","profileIconId":7,"summonerLevel":30,"revisionDate":1442062990000}}', 
		headers: {})
	end

	test "ticket builds new summoner" do
		name_summoner = "theoddone"
		name_duo = "Annie Bot"
		assert_difference('Summoner.count', 2) do
			ticket_params = {
				tournament_id: @tournament.id, 
				summonerName: name_summoner, 
				duoName: name_duo, 
				contact_email: "", 
				contact_first_name: "", 
				contact_last_name: ""}
			ticket = Ticket.new_with_summoner(ticket_params)
			Rails.logger.info "TICKR HERE: #{ticket.inspect}"
			assert_equal ticket.summoner.summonerName, name_summoner
			assert_equal ticket.duo.summonerName, name_duo
		end
	end
end
