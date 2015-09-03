class SummonerTeam < ActiveRecord::Base
	belongs_to :summoner
	belongs_to :team
end
