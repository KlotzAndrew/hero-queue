require 'test_helper'
require_relative '../../../lib/hero_queue/fetcher/lolkingelo'

class LolkingeloTest < ActiveSupport::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
	end

	test "correctly fetches summoner elo" do
		VCR.use_cassette("lolking_nokogiri") do
			fetcher = Fetcher::Lolkingelo.new(@tournament)
			
			@tournament.all_solos.each do |x|
				assert_not x.first.elo.nil?
			end
			@tournament.all_duos.each do |x, y|
				assert_not x.elo.nil?
				assert_not y.elo.nil?
			end
		end
	end
end