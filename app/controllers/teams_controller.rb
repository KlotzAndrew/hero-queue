class TeamsController < ApplicationController
  before_action :set_tournament_teams, only: [:index]
  before_action :set_admin_values, only: [:index]
  before_action :set_teams_if_approved, only: [:index]

  def index
  end

  private
    def set_tournament_teams
      @tournament = Tournament.find(params["tournament_id"])
      @teams ||= []
    end

    def set_admin_values
      if current_user && current_user.admin?
        @tickets = @tournament.tickets.includes(:summoner, :duo).where.not(status: nil)
        @team_stats = @tournament.team_statistics
      end
    end

    def set_teams_if_approved
      if @tournament.teams_approved == true
        @teams = @tournament.teams
      elsif current_user && current_user.admin?
        @teams = @tournament.teams
      end
    end
end
