require "test_helper"

class CanPurchaseTicketTest < ActionDispatch::IntegrationTest
  test "annonymous user can purcahse ticket" do
    visit root_path
    click_on('Join Tournament')
    click_on('Solo Ticket')
    # fill_in('ticket_summonerName', :with => 'BoxStripe')
    click_on('Add Summoner & Contact Info')
    save_and_open_page
  end
end
