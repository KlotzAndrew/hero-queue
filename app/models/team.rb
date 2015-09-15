class Team < ActiveRecord::Base
	belongs_to :tournament
	has_many :summoner_teams
	has_many :summoners, :through => :summoner_teams
end
