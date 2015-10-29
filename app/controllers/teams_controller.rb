class TeamsController < ApplicationController
  before_action :set_tournament_teams, only: [:index]

  def index
  end

  private
    def set_tournament_teams
      @tournament = Tournament.find(params["tournament_id"])
      @teams = @tournament.teams
      if current_user && current_user.admin?
        @tickets = @tournament.tickets.where.not(status: nil)
        @team_stats = @tournament.team_statistics
      end
    end

    def team_params
      params[:team]
    end
end
