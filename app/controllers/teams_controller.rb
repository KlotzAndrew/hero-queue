class TeamsController < ApplicationController
  before_action :set_tournament_teams, only: [:index]
  before_action :set_admin_stats, only: [:index]

  def index
  end

  private
    def set_tournament_teams
      @tournament = Tournament.includes(teams: :summoners, tickets: [:summoner, :duo]).find(params["tournament_id"])
    end

    def set_admin_stats
      if current_user && current_user.admin?
        @team_stats = @tournament.team_statistics
      end
    end
end
