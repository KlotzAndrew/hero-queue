module ApplicationHelper
	def full_title(page_title = '')
	    base_title = "HeroQueue, enter solo win as a team"
	    if page_title.empty?
			base_title
	    else
			page_title + " | " + base_title
	    end
	end	

	def tournament_duration(time)
		time.strftime("%A %b. %-d, %l:00%P") + " - " + (time + 8.hours).strftime("%l:00%P")
	end
end
