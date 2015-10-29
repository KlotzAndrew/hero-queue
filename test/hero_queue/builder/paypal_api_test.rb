require 'test_helper'
require_relative '../../../lib/hero_queue/builder/paypal_api'

class PaypalApiTest < ActionController::TestCase
	ROOT_URL = 'http://localhost:3000'

	def setup
		@ticket = tickets(:openSSL)
	end

	test "generates openSSL ticket link" do
		ssl_value = Builder::PaypalApi.paypal_encrypted(@ticket, ROOT_URL, ROOT_URL)
		assert_equal 2728, ssl_value.length
	end
end