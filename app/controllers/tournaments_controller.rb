class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :update, :update_summoners_elo, :create_tournament_teams]
  before_action :set_ticket, only: [:show]
  before_action :logged_in_user, only: [:update, :update_summoners_elo, :create_tournament_teams]
  before_action :admin_user, only: [:update, :update_summoners_elo, :create_tournament_teams]

  def index
    @upcoming = Tournament.upcoming
    @past = Tournament.past
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
      session[:tournament_id] = @tournament.id
    end

    def set_ticket
      @ticket = @tournament.tickets.where(id: (session[:ticket_id])).first || @tournament.tickets.build
    end

    def tournament_params
      params.require(:tournament).permit(:options)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
