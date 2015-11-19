require 'test_helper'

class SeriesParticipationTest < ActiveSupport::TestCase
  def setup
  	@series_participation = SeriesParticipation.new(
  		series_id: 1,
  		summoner_id: 1)
  end

  test "series_id should be present" do
  	@series_participation.series_id = nil
  	assert_not @series_participation.save
  end

  test "summoner_id should be present" do
  	@series_participation.summoner_id = nil
  	assert_not @series_participation.save
  end
end
