class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: [:hook]

  def create
    @ticket = Ticket.new_with_summoner(ticket_params)
    @errors = @ticket.errors.full_messages

    respond_to do |format|
      if @ticket.save
        format.html { redirect_to tournaments_path(@ticket.tournament.id), notice: 'Ticket was successfully created.' }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def hook
    params.permit! # Permit all Paypal input params
    Ticket.check_paypal_ipn(params)
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:summonerName, :duoName, :contact_email, :contact_first_name, :contact_last_name, :tournament_id)
    end
end
