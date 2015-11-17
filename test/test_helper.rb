require 'simplecov'
SimpleCov.start do
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
  add_group "Libs", "lib/hero_queue"
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
require 'webmock/minitest'
require 'capybara/rails'
require 'selenium-webdriver'
# require 'capybara/poltergeist'

Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper
  # include Capybara::DSL

  def build_demo_teams(tournament)
    all_summoners = tournament.all_solos + tournament.all_duos.flatten
    all_summoners.in_groups_of(5) do |summoners|
      team = Team.create(tournament_id: tournament.id)
      summoners.each do |summoner| 
        tournament.tournament_participations.create!(
          summoner_id: summoner.id,
          team_id: team.id)
      end
    end
  end

	def is_logged_in?
    !session[:user_id].nil?
  end

  def log_in_as(user, options = {})
    password = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: { 
        email: user.email,
        password: password,
        remember_me: remember_me }
    else
      session[:user_id] = user.id
    end
  end

  private

    def integration_test?
      defined?(post_via_redirect)
    end  
	
  	VCR.configure do |config|
  		config.cassette_library_dir = "fixtures/vcr_cassettes"
  		config.hook_into :webmock
  		config.default_cassette_options = {
        match_requests_on: [:uri],
  	    record: :new_episodes }
        config.ignore_localhost = true
  	end
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
end
