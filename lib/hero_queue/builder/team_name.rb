module Builder
	class TeamName
		def initialize
		end

		def random_name
			build_team_name
		end

		private

			def build_team_name
				select_word(league_divisions)
			end

			def select_word(word)
				word.sample(1).first.capitalize
			end

			def league_divisions
				divisions = ["Adepts", "Adventurers", "Agents", "Alchemists", "Alliances", "Allies", "Ambassadors", "Amethysts", "Apprentices", "Archangels", "Archers", "Archons", "Armies", "Arrows", "Arsenals", "Artilleries", "Ascendeds", "Assassins", "Avatars", "Avengers", "Backstabbers", "Bandits", "Banshees", "Barbarians", "Barracudas", "Bats", "Battlemasters", "Bears", "Beasts", "Berserkers", "Blackguards", "Blades", "Blightlords", "Bloodthirsters", "Braves", "Brigades", "Brigands", "Broods", "Brotherhoods", "Brutes", "Buddies", "Butchers", "Captains", "Cavaliers", "Cavalries", "Chains", "Cheetahs", "Chimeras", "Chosens", "Clans", "Cobras", "Colossis", "Commanders", "Commandos", "Conquerors", "Constellations", "Corruptors", "Councils", "Crusaders", "Crushers", "Curses", "Cutthroats", "Cyclops", "Daggers", "Darknesses", "Dawnbringers", "Deceivers", "Defiants", "Demolishers", "Dervishes", "Destinies", "Destroyers", "Disciples", "Dooms", "Dragons", "Dragoons", "Dreadbornes", "Duelists", "Eagles", "Elementalists", "Elites", "Emeralds", "Emmissaries", "Enforcers", "Enlighteneds", "Executioners", "Exemplars", "Fighters", "Fists", "Flames", "Foxes", "Furies", "Gadgeteers", "Giants", "Gladiators", "Gryphons", "Guardians", "Guilds", "Harbingers", "Hawks", "Heralds", "Heroes", "Highborns", "Highwaymen", "Hordes", "Hosts", "Hunters", "Hurricanes", "Iceborns", "Infantries", "Infiltrators", "Inquisitors", "Jackals", "Judicators", "Justicars", "Knights", "Lancers", "Legends", "Legions", "Liberators", "Lifedrinkers", "Lights", "Lightbringers", "Lightnings", "Lions", "Lords", "Magis", "Marauders", "Marksmen", "Masterminds", "Maulers", "Mercenaries", "Messengers", "Minotaurs", "Monks", "Musketeers", "Necromancers", "Ninjas", "Omen", "Opals", "Oracles", "Outlaws", "Outriders", "Overlords", "Owls", "Paladins", "Panthers", "Paragons", "Patriots", "Pearls", "Phantoms", "Pirates", "Poisoners", "Privateers", "Protectors", "Pumas", "Pyromancers", "Rageborns", "Rangers", "Ravagers", "Ravens", "Reapers", "Redeemers", "Regiments", "Renegades", "Ritualists", "Rogues", "Runemasters", "Sapphires", "Scimitars", "Scions", "Scorpions", "Scouts", "Sentinels", "Sentries", "Shadehunters", "Shadowdancers", "Shadows", "Shamans", "Sharks", "Sheriffs", "Shields", "Slayers", "Snipers", "Soldiers", "Songs", "Sorcerers", "Spellbreakers", "Spellslingers", "Spellswords", "Spies", "Stags", "Stalkers", "Standards", "Storms", "Strategists", "Summoners", "Swarms", "Swasbucklers", "Swashbucklers", "Templars", "Thieves", "Tigers", "Tornadoes", "Tricksters", "Troops", "Tyrants", "Urfriders", "Vampires", "Vanguards", "Vengeances", "Veterans", "Vigilantes", "Villains", "Vindicators", "Voidlings", "Vultures", "Wardens", "Warlocks", "Warlords", "Warmongers", "Warriors", "Weaponmasters", "Weapons", "Wisemen", "Witches", "Hunters", "Wizards", "Wraiths", "Zealots", "Zephyrs"]
			end
	end
end