class TeamsController < ApplicationController
  before_action :set_tournament_teams, only: [:index]
  before_action :set_admin_stats, only: [:index]
  before_action :set_team, only: [:update]
  before_action :admin_user, only: [:update]

  def index
  end

  def update
    @team.update(team_params)
    redirect_to tournament_teams_path(params[:tournament_id])
  end

  private
    def set_team
      @team = Team.find(params[:id])
    end

    def set_tournament_teams
      @tournament = Tournament.includes(teams: [:summoners,:absent_summoners], tickets: [:summoner, :duo]).find(params["tournament_id"])
    end

    def set_admin_stats
      if current_user && current_user.admin?
        @team_stats = @tournament.team_statistics
      end
    end

    def team_params
      params.require(:team).permit(:position)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
