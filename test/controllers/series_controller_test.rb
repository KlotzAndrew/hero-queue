require 'test_helper'

class SeriesControllerTest < ActionController::TestCase
	def setup
		@series = series(:basic)
	end

  test "should show series" do
    get :show, id: @series
    assert_response :success
  end
end
