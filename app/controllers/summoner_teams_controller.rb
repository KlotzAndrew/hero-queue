class SummonerTeamsController < ApplicationController
	before_action :set_summoner_team, only: [:update]

	def index
		@summoner_teams = SummonerTeam.includes(:summoner).where(team_id: params["team_id"])
		@ringer = SummonerTeam.new
	end

	def update
		@summoner_team.update(summoner_team_params)
		redirect_to tournament_team_summoner_teams_path(@summoner_team.team.tournament, @summoner_team.team)
	end

	def create
		summoner = Summoner.find_or_create(params[:summoner_team][:summonerName])
		if summoner.id 
			SummonerTeam.transaction do
				SummonerTeam.create!(
					team_id: params[:team_id],
					summoner_id: summoner.id)
				Ticket.create(
					summoner_id: params[:summoner_id],
					tournament_id: params[:tournament_id],
					status: "Ringer")
			end
		end
		redirect_to tournament_team_summoner_teams_path(params[:tournament_id], params[:team_id])
	end

	private
		def set_summoner_team
			@summoner_team = SummonerTeam.find(params[:id])
		end

		def summoner_team_params
      params.require(:summoner_team).permit(:absent)
    end
end
