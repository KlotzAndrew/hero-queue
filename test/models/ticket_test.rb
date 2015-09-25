require 'test_helper'

class TicketTest < ActiveSupport::TestCase

	def setup
		@tournament = tournaments(:tournament_unsold)
	end

	test "ticket builds new summoner" do
		name_summoner = "theoddone"
		name_duo = "Annie Bot"
		VCR.use_cassette("lol_summoners") do
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
end
