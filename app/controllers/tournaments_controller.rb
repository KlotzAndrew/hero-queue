class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show]

  def index
    @upcoming = Tournament.all.where("start_date > ?", Time.now)
    @past = Tournament.all.where("start_date < ?", Time.now)
    @legacy_tours = Tournament.legacy
  end

  def show
    @ticket = Ticket.new(tournament_id: @tournament.id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tournament_params
      params[:tournament]
    end
end
