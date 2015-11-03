module TournamentsHelper
	def tournament_start(time)
		time.strftime("%Y; %B %-d, %l%P")
	end

	def tournaments_link(tournament)
		if tournament.seats_left > 0
			link_to 'Join!', tournament, :class => "btn btn-success"
		else
			link_to 'Sold Out!', tournament, :class => "btn btn-danger"
		end
	end

	def tournament_teams(tournament)
		Rails.cache.fetch("#{tournament.cache_key}/tournament_teams") do
			if tournament.teams.count > 0
				link_to 'View Teams', tournament_teams_path(tournament), :class => "btn btn-primary"
			else
				link_to 'View Teams', tournament_teams_path(tournament), :class => "btn btn-default"
			end
		end
	end
end
