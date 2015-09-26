class Ticket < ActiveRecord::Base
	belongs_to :tournament
	belongs_to :summoner
	belongs_to :duo, :class_name => "Summoner", :foreign_key => "duo_id"

	validates :summoner_id, presence: true
	validate :are_remaining_tickets?

	scope :paid, -> {where(status: "Completed")}
	scope :unpaid, -> {where("status != ? OR status IS ?", "Completed", nil)}

	scope :solo_tickets, -> {where(duo_id: nil)}
	scope :duo_tickets, -> {where.not(duo_id: nil)}

	attr_accessor :summonerName, :duoName, :duo_selected

	#this should be an instance method
	def new_with_summoner(ticket_params)
		Rails.logger.info "STEP1 : WE GOT HERE"
	    if ticket_params[:summonerName]
		    add_summoner(ticket_params[:summonerName])
		end

	    if ticket_params[:duoName]
	    	add_duo(ticket_params[:duoName])
	    end

	    Rails.logger.info "errors final1: #{self.errors.full_messages}"
	    return self
	end

	def add_summoner(summonerName)
		summoner = Summoner.find_or_create(summonerName)
		Rails.logger.info "summoner: #{summoner.inspect}"
		# self.transfer_errors(summoner)
		Rails.logger.info "errors after: #{self.errors.messages}"
		if !!summoner.id 
			self.summoner_id = summoner.id
		end
	end

	def add_duo(duoName)
	    if duoName && duoName.length > 1
	    	duo = Summoner.find_or_create(duoName, "duo name")
	    	# self.transfer_errors(duo)
	    	if !!duo.id
	      		self.duo_id = duo.id 
	    	end
	    end		
	end

	def transfer_errors(obj)
		Rails.logger.info "obj: #{obj.inspect}"
		Rails.logger.info "errors: #{obj.errors.messages}"
		if obj.errors.any?
			obj.errors.messages.each do |x,y|
				self.errors.add(:"#{x}", y.first)
			end
		end
	end

	private

	def are_remaining_tickets?
		remaining = tournament.seats_left
		Rails.logger.info "REMAINING: #{remaining}"
		if duo_id
			seats_for_duo?(remaining) 
		else
			seats_for_solo?(remaining)
		end
		Rails.logger.info "errors: #{self.errors.inspect}"
	end

	def seats_for_solo?(remaining)
		if remaining <= 0
			Rails.logger.info "we should raise solo error!"
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
