class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show]
  before_action :set_ticket, only: [:show]

  def index
    @upcoming = Tournament.all.where("start_date > ?", Time.now)
    @past = Tournament.all.where("start_date < ?", Time.now)
    @legacy_tours = Tournament.legacy
  end

  def show
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
      params[:tournament]
    end
end
