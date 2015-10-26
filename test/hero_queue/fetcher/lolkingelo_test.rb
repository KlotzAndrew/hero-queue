require 'test_helper'
require_relative '../../../lib/hero_queue/fetcher/lolkingelo'

class LolkingeloTest < ActiveSupport::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
	end

	test "correctly fetches summoner elo" do
		VCR.use_cassette("lolking_nokogiri") do
			fetcher = Fetcher::Lolkingelo.new(@tournament)
			
			assert_not_nil @tournament.all_solos.first.first.elo
		end
	end
end