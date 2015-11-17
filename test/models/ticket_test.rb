require 'test_helper'

class TicketTest < ActiveSupport::TestCase
	def setup
		@tournament_sold = tournaments(:tournament_sold)
		@tournament_sold.tickets.last.touch # this was otherwise raising a low-level caching invalidation error for ENV=test
		@summoner = summoners(:boxstripe)
		@ticket = Ticket.new(
			tournament_id: @tournament_sold.id,
			summoner_id: @summoner.id)
	end

	test "ticket tournament_id should be present" do
		@ticket.tournament_id = nil
		assert_not @ticket.valid?
	end

	test "ticket summoner_id should be present" do
		@ticket.summoner_id = nil
		assert_not @ticket.valid?
	end

	test "ticket should require 1 seat for solo" do
		assert_not @ticket.save
	end

	test "ticket should require 2 seat2 for duo" do
		@tournament_sold.increment!(:total_players)
		@ticket.duo_id = 1
		assert_not @ticket.save
	end

	test "paid and unpaid should not overlap" do
		intersection = @tournament_sold.tickets.paid & @tournament_sold.tickets.unpaid
		assert_empty intersection
	end

	test "ticket solo and duo cannot be the same person" do
		@tournament_sold.tickets.delete_all
		@ticket.duo_id = @ticket.summoner_id
		assert_not @ticket.save
	end

	test "tickets cannot be purchased after teams approved" do
		@tournament_sold.increment!(:total_players)
		@tournament_sold.update(teams_approved: true)
		assert_not @ticket.save
	end

	test "summoner can only appear once on tournament[:id]/tickets" do
	end
end
