class TicketsController < ApplicationController
  protect_from_forgery except: [:hook]
  before_action :logged_in_user, only: [:update]
  before_action :admin_user, only: [:update]
  before_action :set_ticket, only: [:update]

  def create
    @ticket = Ticket.new(ticket_params)
    if @ticket.summonerName
      create_new_ticket
      respond_to do |format|
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

  def update
    tournament = @ticket.tournament
    @ticket.update_ticket_remove_participation(refund_params)
    redirect_to tournament_teams_path(tournament)
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

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def create_new_ticket
      @ticket.new_with_summoner(ticket_params)
      @ticket.teams_already_built?
      @ticket.save
      session[:ticket_id] = @ticket.id
    end

    def refund_params
      params.require(:ticket).permit(:status)
    end

    def ticket_params
      params.require(:ticket).permit(:summonerName, :duoName, :contact_email, :contact_first_name, :contact_last_name, :tournament_id, :duo_selected)
    end
end
