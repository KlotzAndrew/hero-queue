class TournamentParticipation < ActiveRecord::Base
	belongs_to :summoner
	belongs_to :team, touch: true
	belongs_to :tournament
	belongs_to :ticket
	belongs_to :series_participation

	scope :present, -> {where.not(absent: true)}
	scope :absent, -> {where(absent: true)}
	scope :unassigned, -> {where(team_id: nil)}

	scope :solos, -> {where(duo_approved: false)}

	validates :summoner_id, presence: true
	validates :tournament_id, presence: true
	validates :ticket_id, presence: true

	attr_accessor :summonerName

	def self.duos
		duo_hash = where(duo_approved: true).includes(:summoner).each_with_object({}) do |t,h|
			if h.has_key?(t.duo_id)
				h[t.duo_id] << t
			else
				h[t.summoner_id] ||= [t]
			end
		end
		duo_hash.values.map {|x,y| [x.summoner, y.summoner]}
	end

	def self.add_to_team_as_ringer(summonerName, tournament_id, team_id)
		summoner = Summoner.find_or_create(summonerName)
		if summoner.id 
			TournamentParticipation.transaction do
				ticket = summoner.tickets.create!(
					tournament_id: tournament_id,
					status: "Ringer")
				add_summoners_to_tournament(ticket.id, tournament_id, summoner.id, nil, team_id, "Ringer")
			end
		end
	end

	def self.add_summoners_to_tournament(ticket_id, tournament_id, summoner_id, duo_id, team_id = nil, status = nil)
		if duo_id
				create_participation_with_duo(ticket_id, tournament_id, summoner_id, duo_id)
		else
			create_participation_solo(ticket_id, tournament_id, summoner_id, team_id, status)
		end
	end
	
	private

		def self.create_participation_solo(ticket_id, tournament_id, summoner_id, team_id = nil, status = nil)
			TournamentParticipation.create(
				ticket_id: ticket_id,
				tournament_id: tournament_id,
				summoner_id: summoner_id,
				team_id: team_id,
				status: status)
		end

		def self.create_participation_with_duo(ticket_id, tournament_id, summoner_id, duo_id)
			TournamentParticipation.transaction do
				TournamentParticipation.create(
					ticket_id: ticket_id,
					tournament_id: tournament_id,
					summoner_id: summoner_id,
					duo_id: duo_id,
					duo_approved: true)
				TournamentParticipation.create(
					ticket_id: ticket_id,
					tournament_id: tournament_id,
					summoner_id: duo_id,
					duo_id: summoner_id,
					duo_approved: true)
			end
		end
end