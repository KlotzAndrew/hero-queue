class SummonerTeam < ActiveRecord::Base
	belongs_to :summoner
	belongs_to :team

	scope :present, -> {where.not(absent: true)}
	scope :absent, -> {where(absent: true)}

	attr_accessor :summonerName
end
