require 'test_helper'

class TournamentTest < ActiveSupport::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
	end

	test "correctly fetches summoner elo" do
		VCR.use_cassette("lolking_nokogiri") do
			EloLk.new(@tournament)
			
			assert_not_nil @tournament.all_solos.first.first.elo

			# @tournament.all_duos.first
			# 	assert_not_nil x.elo
			# 	assert_not_nil y.elo

			Rails.logger.info "all_elos solo: #{@tournament.all_solos.flatten.map {|x| x.elo}}"
			Rails.logger.info "all_elos dui: #{@tournament.all_duos.flatten.map {|x| x.elo}}"
		end
	end

end