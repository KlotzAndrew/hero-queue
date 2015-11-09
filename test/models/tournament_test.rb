require 'test_helper'

class TournamentTest < ActiveSupport::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
		@tournament_unsold = tournaments(:tournament_unsold)
		@summoner = summoners(:boxstripe)
		@other_summoner = summoners(:hukkk)
	end

	test "should return summoners that have paid" do
		assert_not @tournament_unsold.summoners.include?(@summoner)
		ticket = @tournament_unsold.tickets.new(
			summoner_id: @summoner.id,
			status: "Completed")
		assert ticket.save
		assert @tournament_unsold.summoners.include?(@summoner)
	end

	test "should not return summoners that have not paid" do
		assert_not @tournament_unsold.summoners.include?(@summoner)
		ticket = @tournament_unsold.tickets.new(
			summoner_id: @summoner.id,
			status: "")
		assert ticket.save
		assert_not @tournament_unsold.summoners.include?(@summoner)
	end

	test "returns correct team statistics" do
		build_demo_teams(@tournament)
		stats = @tournament.team_statistics
		assert_equal stats[:team_avg], 7250
		assert_equal stats[:team_std], 1050.0	
		assert_equal stats[:team_max], 8300
		assert_equal stats[:team_min], 6200
	end

	test "tournament has a limit on number of teams" do
		@tournament.total_teams.times do |x| 
			@tournament.teams << @tournament.teams.create
		end
		assert_equal @tournament.total_teams, @tournament.teams.count
		@tournament.teams << @tournament.teams.create
		assert_equal @tournament.total_teams, @tournament.teams.count
	end
	
	test "player_count returns corrent number" do
		assert_equal 10, @tournament.player_count
	end

	test "seats_left returns corrent number" do
		assert_equal 0, @tournament.seats_left
	end

	test "all_solos returns corrent number" do
		assert_equal 4, @tournament.all_solos.count
	end

	test "all_duos returns corrent number" do
		assert_equal 3, @tournament.all_duos.count
		assert_equal 6, @tournament.all_duos.flatten.count
	end

	test "upcoming correctly returns upcoming tournaments" do
		assert_equal Tournament.where("start_date > ?", Time.now).order(start_date: :asc).map(&:id), Tournament.upcoming.map(&:id)
	end

	test "past correctly returns past tournaments" do
		assert_equal Tournament.where("start_date < ?", Time.now).order(start_date: :asc).map(&:id), Tournament.past.map(&:id)
	end
end
