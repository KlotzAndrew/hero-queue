source 'https://rubygems.org'
require 'open-uri'
require 'net/http'

gem 'rails', '4.2.3'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'nokogiri', '~> 1.6.6.2'

gem 'bcrypt', '~> 3.1.7'
gem 'descriptive_statistics'
# gem 'unicorn'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem "bullet"
  gem 'capybara'
end

group :test do
	gem 'minitest-reporters', '1.0.5'
	gem 'guard-minitest', '2.3.1'
	gem 'mini_backtrace',     '0.1.3'
  gem 'webmock', '1.21.0'
  gem 'vcr', '~> 2.9.3'
  gem 'simplecov', :require => false
end

group :production do
	gem 'pg'
	gem 'rails_12factor'
  gem 'memcachier'
  gem 'dalli'
end

group :development do
  gem 'rack-mini-profiler'
end