class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :update]
  before_action :set_ticket, only: [:show]
  before_action :logged_in_user, only: [:update]
  before_action :admin_user, only: [:update]

  def index
    @upcoming = Tournament.all.where("start_date > ?", Time.now)
    @past = Tournament.all.where("start_date < ?", Time.now)
    @legacy_tours = Tournament.legacy
  end

  def show
  end

  def update
    #maybe case when
    if params[:options] == "lolkingelo"
      @tournament.update_summoner_elos
    elsif params[:options] == "buildteams"
      @tournament.update_with_teambalancer
    end
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
