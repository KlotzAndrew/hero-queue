require 'test_helper'

class TeamNameTest < ActiveSupport::TestCase
	def setup
	end

	test "correctly returns a team name string" do
		builder = Builder::TeamName.new
		team_name = builder.random_name
		assert_not_nil team_name
		assert_equal String, team_name.class
	end
end