require 'test_helper'
require_relative '../../../lib/hero_queue/fetcher/lolkingelo'

class LolkingeloTest < ActiveSupport::TestCase
	def setup
		@tournament = tournaments(:tournament_sold)
		Summoner.all.each {|x| x.update(elo: nil)}
	end

	test "correctly fetches summoner elo" do
		VCR.use_cassette("lolking_nokogiri") do
			summoners_array = @tournament.all_solos.flatten + @tournament.all_duos.flatten
			fetcher = Fetcher::Lolkingelo.new(summoners_array)
			fetcher.update_summoners_elo

			@tournament.all_solos.each do |x|
				assert_not x.elo.nil?
			end
			@tournament.all_duos.each do |x, y|
				assert_not x.elo.nil?
				assert_not y.elo.nil?
			end
		end
	end
end