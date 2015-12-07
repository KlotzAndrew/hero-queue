class Ticket < ActiveRecord::Base
	belongs_to :tournament, touch: true
	belongs_to :summoner
	belongs_to :duo, :class_name => "Summoner"
	has_many :tournament_participations

	validates :tournament_id, presence: true
	validates :summoner_id, presence: true

	before_create :are_remaining_tickets?
	before_create :duo_is_not_you?
	before_create :is_tournament_canceled?
	# before_create :teams_already_built?

	scope :paid, -> {where(status: ["Completed","Pending","Ringer"])}
	scope :unpaid, -> {where.not(status: ["Completed","Pending","Ringer"])}
	scope :ringers, -> {where(status: ["Ringer"])}

	scope :solo_tickets, -> {where(duo_id: nil)}
	scope :duo_tickets, -> {where.not(duo_id: nil)}

	attr_accessor :summonerName, :duoName, :duo_selected

	def update_ticket_remove_participation(refund_params)
		if refund_params[:status] == "Refunded"
			ActiveRecord::Base.transaction do
				self.update(status: refund_params[:status])
				self.tournament_participations.destroy_all
			end
		end
	end

	def new_with_summoner(ticket_params)
	    add_summoner(ticket_params[:summonerName]) if ticket_params[:summonerName]
	    add_duo(ticket_params[:duoName]) if ticket_params[:duoName]
	    return self
	end

	def teams_already_built?
		if self.tournament.teams_approved && self.status != "Ringer"
			self.errors.add(:too_late, ", sorry teams have already been built!")
			return false
		end
	end

	def self.check_paypal_ipn(params)
		status = params[:payment_status]
	    if status == "Completed"
	    	# check reciever email is my paypal email
	    	# elsif response.body == VERIFIED or INVALID
	      ticket = Ticket.find(params[:invoice])
	      ticket.update(
	        notification_params: params,
	        status: status,
	        transaction_id: params[:txn_id],
	        purchased_at: Time.now)
	      self.paypal_verify(ticket)
	      ticket.add_players_to_tournament
	     elsif status == "Pending"
	     	ticket = Ticket.find(params[:invoice])
	      ticket.update(
	        notification_params: params,
	        status: status,
	        transaction_id: params[:txn_id],
	        purchased_at: Time.now)
	      self.paypal_verify(ticket)
	      ticket.add_players_to_tournament
	    end
	end

	def add_players_to_tournament
		TournamentParticipation.add_summoners_to_tournament(self.id, self.tournament_id, self.summoner_id, self.duo_id)
		Series.add_summoners_to_series(self.tournament, self.summoner_id, self.duo_id) if self.tournament.series
	end

	private

		def is_tournament_canceled?
			if self.tournament.canceled?
				self.errors.add(:too_late, ", sorry tournament has been canceled!")
				return false
			end
		end

		def self.paypal_verify(ticket)
			raw_body = JSON.parse(ticket.notification_params.gsub('\\','').gsub('=>',':'))
			uri = URI.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
			request = Net::HTTP.post_form(uri, raw_body)
		end


		def duo_is_not_you?
			return false if self.summoner_id == self.duo_id
		end

		def add_summoner(summonerName)
			summoner = Summoner.find_or_create(summonerName)
			self.summoner_id = summoner.id unless summoner.id.nil?
		end

		def add_duo(duoName)
		    if duoName && duoName.length > 1
		    	duo = Summoner.find_or_create(duoName, "duo name")
	      		self.duo_id = duo.id unless duo.id.nil?
		    end
		end

		def are_remaining_tickets?
			remaining = tournament.seats_left
			duo_id == nil ? seats_for_solo?(remaining) : seats_for_duo?(remaining)
		end

		def seats_for_solo?(remaining)
			if remaining <= 0
				self.errors.add(:sold_out, ", sorry there are no tickets left!")
				return false
			end
		end

		def seats_for_duo?(remaining)
			if remaining <= 1
				self.errors.add(:only_one, "seat left! Unable to register a duo")
				return false
			end
		end
end
