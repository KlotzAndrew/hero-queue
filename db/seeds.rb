# This is raw data so dev env will match 3rd party connections
sumName = ["1st time draven", "OBJCorrupt", "OBJControl", "Wisecracker", "CsXploit", "Dubyaa", "Rootfifth", "GoodolJohnny", "DragonsoldierX", "EroticIntentions", "Ayfoo", "Hobowhoeatspie", "LiLiLiLLiii", "HHGundam", "ShadowTip148", "Twistblader", "DrBillyHorrible", "Axl753", "MiceGoRawr", "SSGGosu", "WilliamYe2", "9xDragonz", "Kinshu", "MandaloreIV", "SumofAllBlobs", "PaulAcaust", "FluffyPoro", "Galad15", "IdontsmurfGG", "6ftboss", "LeeFish", "TheRealCasanova", "Teixmexx", "Formulation", "GlorpBall123", "Suptnk", "808Mclovin", "Neron643", "Sooeng", "dawnbringer"]
sumName_ref = ["1sttimedraven", "objcorrupt", "objcontrol", "wisecracker", "csxploit", "dubyaa", "rootfifth", "goodoljohnny", "dragonsoldierx", "eroticintentions", "ayfoo", "hobowhoeatspie", "lilililliii", "hhgundam", "shadowtip148", "twistblader", "drbillyhorrible", "axl753", "micegorawr", "ssggosu", "williamye2", "9xdragonz", "kinshu", "mandaloreiv", "sumofallblobs", "paulacaust", "fluffyporo", "galad15", "idontsmurfgg", "6ftboss", "leefish", "therealcasanova", "teixmexx", "formulation", "glorpball123", "suptnk", "808mclovin", "neron643", "sooeng", "dawnbringer"]
sumids = [19767256, 59971, 190291, 50792756, 47524500, 33371029, 23579633, 19076808, 30086184, 26286097, 19883284, 31414894, 51061375, 20475536, 50957304, 23356830, 19962583, 23671363, 32949008, 34186865, 38800794, 30082045, 30239378, 42251623, 45720107, 65009335, 23213768, 27335174, 93004, 20398292, 33079323, 49324698, 35512658, 32524121, 30261720, 52469091, 29811963, 20183196, 27210198, 20103383]

User.create!(
	name: "tester",
	email: "test@test.com",
	password: "password",
	password_confirmation: "password",
	activated_at: Time.zone.now,
	admin: true,
	activated: true,
	)

series = Series.create!(
	name: "Winter Series")

Tournament.create!(
	name: "Solo/Duo Queue League Tournament",
	game: "League of Legends",
	total_players: 40,
	total_teams: 8,
	price: 15.00,
	start_date: 4.weeks.ago,
	location_name: "Happy Turbo Internet Cafe",
	location_address: "5171 Yonge St.",
	location_url: "http://www.happyturbo.com",
	facebook_url: "https://www.facebook.com")


1.upto(4) do |x|
	series.tournaments.create!(
		name: "Solo/Duo Queue League Tournament (#{x})",
		game: "League of Legends",
		total_players: 40,
		total_teams: 8,
		price: 15.00,
		start_date: Time.now + x.weeks,
		location_name: "Happy Turbo Internet Cafe",
		location_address: "5171 Yonge St.",
		location_url: "http://www.happyturbo.com",
		facebook_url: "https://www.facebook.com")
end

0.upto(sumName.count-1) do |x|
	summoner = Summoner.create!(
		summonerName: sumName[x],
		summoner_ref: sumName_ref[x],
		summonerId: sumids[x],
		summonerLevel: 30,
		profileIconId: "6")
end

SUMMONERS_TO_DUOS = 20
DUO_SIZE = 2
duo_and_solo_summoner_array = Summoner.all.each_slice(SUMMONERS_TO_DUOS).to_a
tournament = Tournament.upcoming.first
series = tournament.series || nil

duo_and_solo_summoner_array.first.each_slice(DUO_SIZE).to_a.each do |x,y|
	ticket = tournament.tickets.create!(
		summoner_id: x.id,
		duo_id: y.id,
		status: "Completed")
	series_participation = SeriesParticipation.create!(
			series_id: tournament.series.id,
			summoner_id: x.id)
	tournament_participation = TournamentParticipation.create!(
		ticket_id: ticket.id,
		tournament_id: tournament.id,
		summoner_id: x.id,
		duo_id: y.id,
		duo_approved: true,
		series_participation_id: series_participation.id)
	series_participation = SeriesParticipation.create!(
			series_id: tournament.series.id,
			summoner_id: y.id)
	tournament_participation = TournamentParticipation.create!(
		ticket_id: ticket.id,
		tournament_id: tournament.id,
		summoner_id: y.id,
		duo_id: x.id,
		duo_approved: true,
		series_participation_id: series_participation.id)
end

duo_and_solo_summoner_array.last.each do |x|
	ticket = tournament.tickets.create!(
		summoner_id: x.id,
		status: "Completed")
	series_participation = SeriesParticipation.create!(
			series_id: tournament.series.id,
			summoner_id: x.id)
	TournamentParticipation.create!(
		ticket_id: ticket.id,
		tournament_id: tournament.id,
		summoner_id: x.id,
		series_participation_id: series_participation.id)
end