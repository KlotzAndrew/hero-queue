class Tournament < ActiveRecord::Base
	has_many :tickets
	has_many :teams

	
end
