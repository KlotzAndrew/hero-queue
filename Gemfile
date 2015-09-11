source 'https://rubygems.org'
require 'open-uri'

gem 'rails', '4.2.3'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

# gem 'bcrypt', '~> 3.1.7'
# gem 'unicorn'

group :development, :test do
  gem 'sqlite3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

group :test do
	gem 'minitest-reporters', '1.0.5'
	gem 'guard-minitest', '2.3.1'
	gem 'mini_backtrace',     '0.1.3'
end

group :production do
	gem 'pg'
	gem 'rails_12factor'
end