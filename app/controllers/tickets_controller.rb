class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show]
  protect_from_forgery except: [:hook]

  def create
    if params[:commit] == "Solo Ticket" or params[:commit] == "Solo Ticket"
      @ticket = Ticket.new(ticket_params)
    else
      @ticket = Ticket.new_with_summoner(ticket_params)
    end

    @errors = @ticket.errors.full_messages
    respond_to do |format|
      if @ticket.save
        format.html { redirect_to tournament_path(@ticket.tournament.id, :active_ticket => @ticket)}
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def hook
    params.permit! # Permit all Paypal input params
    PaypalApi.check_paypal_ipn(params)
    Rails.logger.info "PAYPAL_IPN params: #{params}"
    Rails.logger.info "PAYPAL_IPN request.body.string: #{request.body.string}"
    Rails.logger.info "PAYPAL_IPN request.body.string.lenght: #{request.body.string.length}"
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:summonerName, :duoName, :contact_email, :contact_first_name, :contact_last_name, :tournament_id, :duo_selected)
    end
end
