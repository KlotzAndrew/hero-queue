class Ticket < ActiveRecord::Base
	belongs_to :tournament
	belongs_to :summoner
	belongs_to :duo, :class_name => "Summoner", :foreign_key => "duo_id"

	validates :summoner_id, presence: true
	validate :there_are_remaining_tickets

	attr_accessor :summonerName, :duoName, :duo_selected

	def there_are_remaining_tickets
		sold = ApplicationController.helpers.seats_taken(self.tournament)
		remaining = self.tournament.total_players
		self.seats_for_solo?(sold, remaining)
		if self.duo_id then self.seats_for_duo?(sold, remaining) end
	end

	def seats_for_solo?(sold, remaining)
		if sold >= remaining
			errors.add(:sold_out, ", sorry there are no tickets left!")
		end
	end

	def seats_for_duo?(sold, remaining)
		if sold >= remaining - 1
			errors.add(:only_one, "seat left! Unable to register a duo")
		end
	end

	def self.new_with_summoner(ticket_params)
	    ticket = Ticket.new(ticket_params)

	    if ticket_params[:summonerName]
		    ticket.add_summoner(ticket_params[:summonerName])
		end

	    if ticket_params[:duoName]
	    	ticket.add_duo(ticket_params[:duoName])
	    end

	    Rails.logger.info "errors final1: #{ticket.errors.full_messages}"
	    return ticket 
	end

	def add_summoner(summonerName)
		summoner = Summoner.find_or_create(summonerName)
		Rails.logger.info "summoner: #{summoner.inspect}"
		self.transfer_errors(summoner)
		Rails.logger.info "errors after: #{self.errors.messages}"
		if !!summoner.id 
			self.summoner_id = summoner.id
		end
	end

	def add_duo(duoName)
	    if duoName && duoName.length > 1
	    	duo = Summoner.find_or_create(duoName, "duo name")
	    	self.transfer_errors(duo)
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
end
