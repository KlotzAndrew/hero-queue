class Team < ActiveRecord::Base
	belongs_to :tournament
	has_many :summoner_teams
	has_many :summoners, :through => :summoner_teams

	def self.build_teams(tournament)
		team_counter()
	end

	def self.team_counter
		puts "privatee"
	end
end
