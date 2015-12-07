module TournamentsHelper
	def tournament_start(time)
		time.strftime("%b. %-d, %l%P")
	end

	def tournaments_link(tournament)
		if tournament.canceled
			link_to 'Canceled!', tournament, :class => "btn btn-warning"
		elsif tournament.seats_left > 0
			link_to 'Join!', tournament, :class => "btn btn-success"
		else
			link_to 'Sold Out!', tournament, :class => "btn btn-danger"
		end
	end
end
