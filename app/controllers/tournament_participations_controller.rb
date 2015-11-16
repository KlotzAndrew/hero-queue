class TournamentParticipationsController < ApplicationController
	before_action :set_tournament_participation, only: [:update, :destroy]
	before_action :logged_in_user, only: [:index, :create, :update, :destroy]
	before_action :admin_user, only: [:index, :update, :create, :destroy]
	before_action :set_ringer_ticket, only: [:destroy, :update]


	def index
		@tournament_participations = TournamentParticipation.includes(:summoner).where(team_id: params["team_id"])
		@ringer = TournamentParticipation.new
	end

	def update
		if @tournament_participation.team_id.nil?
			@tournament_participation.update(tournament_participation_teamid_params)
		elsif @ringer_ticket && tournament_participation_params[:absent] == "true"
			@ringer_ticket.destroy
			@tournament_participation.destroy
		else
			@tournament_participation.update(tournament_participation_params)
		end
		redirect_to tournament_team_tournament_participations_path(@tournament_participation.team.tournament, @tournament_participation.team)
	end

	def create
		TournamentParticipation.add_to_team_as_ringer(params[:tournament_participation][:summonerName], params[:tournament_id], params[:team_id])
		redirect_to tournament_team_tournament_participations_path(params[:tournament_id], params[:team_id])
	end

	def destroy
		if @ringer_ticket
			@ringer_ticket.destroy
			@tournament_participation.destroy
		end
		redirect_to tournament_team_tournament_participations_path(params[:tournament_id], params[:team_id])
	end

	private
		def set_ringer_ticket
			@ringer_ticket = @tournament_participation.team.tournament.tickets.where(status: "Ringer").where(summoner_id: @tournament_participation.summoner_id).first if @tournament_participation.team
		end

		def set_tournament_participation
			@tournament_participation = TournamentParticipation.find(params[:id])
		end

		def tournament_participation_params
      params.require(:tournament_participation).permit(:absent)
    end

    def tournament_participation_teamid_params
    	params.require(:tournament_participation).permit(:team_id)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
