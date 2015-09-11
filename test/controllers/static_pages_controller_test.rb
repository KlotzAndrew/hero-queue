require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  def setup
    @base_title = "HeroQueue, enter solo win as a team"
  end

  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "Home | #{@base_title}"
  end

  test "should get rules" do
    get :rules
    assert_response :success
    assert_select "title", "Rules | #{@base_title}"
  end

  test "should get format" do
    get :format
    assert_response :success
    assert_select "title", "Format | #{@base_title}"
  end

end
