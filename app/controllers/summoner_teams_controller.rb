class SummonerTeamsController < ApplicationController
	before_action :set_summoner_team, only: [:update, :destroy]
	before_action :logged_in_user, only: [:index, :create, :update, :destroy]
	before_action :admin_user, only: [:index, :update, :create, :destroy]
	before_action :set_ringer_ticket, only: [:destroy, :update]


	def index
		@summoner_teams = SummonerTeam.includes(:summoner).where(team_id: params["team_id"])
		@ringer = SummonerTeam.new
	end

	def update
		if @ringer_ticket && summoner_team_params[:absent] == "true"
			@ringer_ticket.destroy
			@summoner_team.destroy
		else
			@summoner_team.update(summoner_team_params)
		end
		redirect_to tournament_team_summoner_teams_path(@summoner_team.team.tournament, @summoner_team.team)
	end

	def create
		summoner_team = SummonerTeam.new
		summoner_team.add_to_team_as_ringer(params[:summoner_team][:summonerName], params[:tournament_id], params[:team_id])

		redirect_to tournament_team_summoner_teams_path(params[:tournament_id], params[:team_id])
	end

	def destroy
		if @ringer_ticket
			@ringer_ticket.destroy
			@summoner_team.destroy
		end
		redirect_to tournament_team_summoner_teams_path(params[:tournament_id], params[:team_id])
	end

	private
		def set_ringer_ticket
			@ringer_ticket = @summoner_team.team.tournament.tickets.where(status: "Ringer").where(summoner_id: @summoner_team.summoner_id).first
		end

		def set_summoner_team
			@summoner_team = SummonerTeam.find(params[:id])
		end

		def summoner_team_params
      params.require(:summoner_team).permit(:absent)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
