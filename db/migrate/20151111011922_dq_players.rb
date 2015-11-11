class DqPlayers < ActiveRecord::Migration
  def change
  	add_column :summoner_teams, :absent, :boolean, default: false
  end
end
