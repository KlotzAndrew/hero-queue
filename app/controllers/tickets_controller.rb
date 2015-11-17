class TicketsController < ApplicationController
  protect_from_forgery except: [:hook]

  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.summonerName
      @ticket.new_with_summoner(ticket_params)
      @ticket.teams_already_built?
      @ticket.save
      session[:ticket_id] = @ticket.id
      respond_to do |format|
        flash[:success] = "Ticket ready for checkout!"
        format.html { redirect_to tournament_path(@ticket.tournament.id, :active_ticket => @ticket)}
        format.js
      end
    elsif @ticket.duo_selected
      respond_to do |format|
        format.html { redirect_to tournament_path(@ticket.tournament.id)}
        format.js 
      end
    end
  end

  def reset_ticket_session
    session[:ticket_id] = nil
    flash[:success] = "Ticket reset!"
    redirect_to controller: 'tournaments', action: 'show', id: session[:tournament_id]
  end

  def hook
    params.permit! # Permit all Paypal input params
    Ticket.check_paypal_ipn(params)
    Rails.logger.info "PAYPAL_IPN params: #{params}"
    Rails.logger.info "PAYPAL_IPN request.body.string: #{request.body.string}"
    Rails.logger.info "PAYPAL_IPN request.body.string.lenght: #{request.body.string.length}"
    render nothing: true
  end

  private
    def ticket_params
      params.require(:ticket).permit(:summonerName, :duoName, :contact_email, :contact_first_name, :contact_last_name, :tournament_id, :duo_selected)
    end
end
