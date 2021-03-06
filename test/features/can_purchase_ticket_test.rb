require "test_helper"

class CanPurchaseTicketTest < ActionDispatch::IntegrationTest
	def setup
		Capybara.default_driver = :selenium
		@summoner = summoners(:boxstripe)
    @duo = summoners(:hukkk)
    @tournament = Tournament.upcoming.first
	end

  test "anonymous user can purchase solo/duo tickets" do
  	VCR.use_cassette("lol_summoners") do
	    #get to tournament
	    visit root_path
	    assert_equal 0, @tournament.summoners.count 
	    #click ticket and reset
	    click_on('Join Tournament')
	    click_on('Solo Ticket')
	    click_on('reset')
	    #fill solo ticket and reset
	    click_on('Solo Ticket')
	    fill_in('Summoner Name', :with => @summoner.summonerName)
	    click_on('Add Summoner & Contact Info')
	    click_on('reset')
	    #fill duo ticket and move to purchase
	    click_on('Duo Ticket')
	    fill_in('Summoner Name', :with => 'BoxStripe')
	    fill_in('Duo Name', :with => 'hukkk')
	    click_on('Add Summoner & Contact Info')
	    click_on('Checkout')
	    # assert_equal "Pay with a debit or credit card - PayPal", page.title
	    ticket = Ticket.where(summoner_id: @summoner.id).where(duo_id: @duo.id).last
	    VCR.use_cassette('outgoing_requests') do
	      post hook_path,
	        payment_status: "Completed",
	        invoice: ticket.id
	    end
	    assert_equal 2, @tournament.summoners.count 
  	end
  end
end
