class TeamsController < ApplicationController
  # before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :set_tournament_teams, only: [:index]

  def index
    # @summoners = Tournament.find(params["tournament_id"]).tickets.where(status: "Completed").map { |ticket| ticket.summoner.summonerName }
  end

  private
    def set_tournament_teams
      @teams = Team.all.where("tournament_id = ?", params["tournament_id"])
    end

    def set_team
      @team = Team.find(params[:id])
    end

    def team_params
      params[:team]
    end
end
