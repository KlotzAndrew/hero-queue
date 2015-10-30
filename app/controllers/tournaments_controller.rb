class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :update, :update_summoners_elo, :create_tournament_teams]
  before_action :set_ticket, only: [:show]
  before_action :logged_in_user, only: [:update, :update_summoners_elo, :create_tournament_teams]
  before_action :admin_user, only: [:update, :update_summoners_elo, :create_tournament_teams]

  def index
    @upcoming = Tournament.all.where("start_date > ?", Time.now)
    @past = Tournament.all.where("start_date < ?", Time.now)
    @legacy_tours = Tournament.legacy
  end

  def show
  end

  def update_summoners_elo
    @tournament.update_summoners_elo
    redirect_to tournament_teams_path(@tournament)
  end

  def create_tournament_teams
    @tournament.create_tournament_teams
    redirect_to tournament_teams_path(@tournament)
  end

  private
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    def set_ticket
      if params[:active_ticket]
        @ticket = Ticket.where("id = ?", params[:active_ticket]).first
      else
        @ticket = Ticket.new(tournament_id: @tournament.id)
      end
    end

    def tournament_params
      params.require(:tournament).permit(:options)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
