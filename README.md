#HeroQueue
eSports app for balanced amateur-level tournaments. Covers registration, drafting, and organization

###Functionality
 * Set up a tournament `Tournament.new(tournament_params)`
 * Fetch player rankings `EloLk.new(Tournament.find(x))`
 * Build balanced teams `Tournament.find(x).build_teams`

###External Integrations
 * League of Legends API
 * PayPal API
 * LolKing noAPI (nokogiri HTML parser)
 
###Next Features
 * Increase team builder speed
 * pretty team index display
 * image gallery
 * teams mailer

###On the horizon
 * tournament bracket display
 * league API auto-fetch tournament game results
 * summoner cumulative scores
 * 'Season has_many Tournaments'
 * admin/volunteer profiles for tournaments
 * pretty volunteer index display
