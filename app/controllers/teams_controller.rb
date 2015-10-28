class TeamsController < ApplicationController
  # before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :set_tournament_teams, only: [:index]

  def index
  end

  private
    def set_tournament_teams
      @tournament = Tournament.find(params["tournament_id"])
      @teams = @tournament.teams
      if current_user && current_user.admin?
        @tickets = @tournament.tickets
        @team_stats = @tournament.team_statistics
      end
    end

    # def set_team
    #   @team = Team.find(params[:id])
    # end

    def team_params
      params[:team]
    end
end
