require 'test_helper'

class SeriesTest < ActiveSupport::TestCase
  def setup
  	@series = series(:winter)
  end

  test "series name should be present" do
  	@series.name = " "
  	assert_not @series.valid?
  end
end
