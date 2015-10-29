require 'test_helper'

class PaypalApiTest < ActionDispatch::IntegrationTest
	def setup
		@ticket = tickets(:openSSL)
	end

	test "generates openSSL ticket link" do
		ssl_value = PaypalApi.paypal_encrypted(@ticket, root_url, root_url)
		assert_equal 2728, ssl_value.length
	end
end