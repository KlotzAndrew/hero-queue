require "test_helper"

class NavigateMainPagesTest < ActionDispatch::IntegrationTest
	def setup
    @base_title = "HeroQueue, enter solo win as a team"
  end

	test "non-logged in user can see main pages" do
		visit root_path
		#rules page
		click_on('Rules')
		assert_equal "Rules | #{@base_title}", page.title
		#format page
		click_on('Format')
		assert_equal "Format | #{@base_title}", page.title
		#prizing page
		click_on('Prizing')
		assert_equal "Prizing | #{@base_title}", page.title
		#home page
		click_on('HeroQueue')
		assert_equal "Home | #{@base_title}", page.title
	end
end