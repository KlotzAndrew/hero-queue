require 'test_helper'

class TournamentControlsTest < ActionDispatch::IntegrationTest
	def setup
		@tournament_sold = tournaments(:tournament_sold)
		@user = users(:grok)
    @other_user = users(:thrall)
	end

	def reset_summoner_elos(tournament)
		tournament.all_solos.each do |x|
			x.first.update(elo: nil)
		end
		tournament.all_duos.each do |x, y|
			x.update(elo: nil)
			y.update(elo: nil)
		end
	end

	# test "admin should build teams for full roster" do
	# 	VCR.use_cassette("lolking_nokogiri") do
	# 		log_in_as(@user)
	# 		assert @user.admin?
	# 		assert_empty @tournament_sold.teams
	# 		patch tournament_path(@tournament_sold), use_class: "buildteams"
	# 		assert_equal @tournament_sold.reload.teams.count, @tournament_sold.total_teams
	# 	end
	# end

	# test "update elos with admin account" do
	# 	VCR.use_cassette("lolking_nokogiri") do
	# 		log_in_as(@user)
	# 		assert @user.admin?
	# 		reset_summoner_elos(@tournament_sold)
	# 		@tournament_sold.all_solos.each do |x|
	# 			assert_nil x.first.elo
	# 		end
	# 		@tournament_sold.all_duos.each do |x, y|
	# 			assert_nil x.elo
	# 			assert_nil y.elo
	# 		end
	# 		patch tournament_path(@tournament_sold), use_class: "lolkingelo"
	# 		assert_not_nil @tournament_sold.all_solos.first.first.elo
	# 		assert_redirected_to tournament_teams_path(@tournament_sold)
	# 	end
	# end

	# test "should not update elos if not logged in" do
	# 	VCR.use_cassette("lolking_nokogiri") do
	# 		reset_summoner_elos(@tournament_sold)
	# 		@tournament_sold.all_solos.each do |x|
	# 			assert_nil x.first.elo
	# 		end
	# 		@tournament_sold.all_duos.each do |x, y|
	# 			assert_nil x.elo
	# 			assert_nil y.elo
	# 		end
	# 		patch tournament_path(@tournament_sold), use_class: "lolkingelo"
	# 		assert_nil @tournament_sold.all_solos.first.first.elo
	# 		assert_redirected_to login_url
	# 	end
	# end

	# test "should not build teams if not admin" do
	# 	VCR.use_cassette("lolking_nokogiri") do
	# 		log_in_as(@other_user)
	# 		assert_not @other_user.admin?
	# 		reset_summoner_elos(@tournament_sold)
	# 		@tournament_sold.all_solos.each do |x|
	# 			assert_nil x.first.elo
	# 		end
	# 		@tournament_sold.all_duos.each do |x, y|
	# 			assert_nil x.elo
	# 			assert_nil y.elo
	# 		end
	# 		patch tournament_path(@tournament_sold), options: "lolkingelo"
	# 		assert_nil @tournament_sold.all_solos.first.first.elo
	# 		assert_redirected_to root_url
	# 	end
	# end		
end
