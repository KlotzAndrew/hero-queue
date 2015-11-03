class Team < ActiveRecord::Base
	belongs_to :tournament, touch: true
	has_many :summoner_teams
	has_many :summoners, :through => :summoner_teams

	before_save :under_max_team_limit

	def self.build_teams(teams, tournament_id)
		teams.each do |team_array|
			team = Team.create(tournament_id: tournament_id)
			team_array.flatten.each { |player| team.summoners << Summoner.find(player[:id]) }
		end
	end

	private

	def under_max_team_limit
		if self.tournament.teams.count >= self.tournament.total_teams
			return false
		end
	end
end
