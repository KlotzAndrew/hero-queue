class AddIndicesToDb < ActiveRecord::Migration
  def change
  	add_index :summoners, :summoner_ref
  	add_index :summoners, :summonerId
  	add_index :summoners, :elo

		add_index :teams, :tournament_id

		add_index :tickets, :summoner_id
		add_index :tickets, :duo_id
		add_index :tickets, :tournament_id
		add_index :tickets, :status
  end
end
