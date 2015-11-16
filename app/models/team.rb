class Team < ActiveRecord::Base
	belongs_to :tournament, touch: true
	
	has_many :tournament_participations
	has_many :assigned_summoners, :through => :tournament_participations

	has_many :summoner_assignments, :class_name => 'TournamentParticipation'
	has_many :assigned_summoners, :source => :summoner, :through => :summoner_assignments

	has_many :absent_assignments, -> {absent}, :class_name => 'TournamentParticipation'
	has_many :absent_summoners, :source => :summoner, :through => :absent_assignments

	has_many :present_assignments, -> {present}, :class_name => 'TournamentParticipation'
	has_many :summoners, :source => :summoner, :through => :present_assignments

	before_create :under_max_team_limit

	scope :order_ranked, -> {order(position: :asc)}

	def self.build_teams(teams, tournament_id)
		teams.each do |team_array|
			team = Team.create(
				tournament_id: tournament_id,
				name: ::Builder::TeamName.new.random_name)
			team_array.flatten.each do |player| 
				summoner_team = TournamentParticipation.where(tournament_id: tournament_id).where(summoner_id: player[:id]).first
				summoner_team.update(team_id: team.id)
			end
		end
	end

	private

	def under_max_team_limit
		if self.tournament.teams.count >= self.tournament.total_teams
			return false
		end
	end
end
