class TournamentParticipationsController < ApplicationController
	before_action :set_tournament_participation, only: [:update, :destroy]
	before_action :logged_in_user, only: [:index, :create, :update, :destroy]
	before_action :admin_user, only: [:index, :update, :create, :destroy]

	def index
		@tournament_participations = TournamentParticipation.includes(:summoner).where(team_id: params["team_id"])
		@ringer = TournamentParticipation.new
	end

	def update
		update_team_or_absent
		redirect_to tournament_team_tournament_participations_path(@tournament_participation.team.tournament, @tournament_participation.team)
	end

	def create
		TournamentParticipation.add_to_team_as_ringer(params[:tournament_participation][:summonerName], params[:tournament_id], params[:team_id])
		redirect_to tournament_team_tournament_participations_path(params[:tournament_id], params[:team_id])
	end

	def destroy
		if @tournament_participation.status == "Ringer"
			@tournament_participation.ticket.destroy
			@tournament_participation.destroy
		end
		redirect_to tournament_team_tournament_participations_path(params[:tournament_id], params[:team_id])
	end

	private

		def update_team_or_absent
			if @tournament_participation.team_id.nil?
				@tournament_participation.update(team_id_params)
			else
				@tournament_participation.update(tournament_participation_params)
			end
		end

		def set_tournament_participation
			@tournament_participation = TournamentParticipation.find(params[:id])
		end

		def tournament_participation_params
      params.require(:tournament_participation).permit(:absent)
    end

    def team_id_params
    	params.require(:tournament_participation).permit(:team_id)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
