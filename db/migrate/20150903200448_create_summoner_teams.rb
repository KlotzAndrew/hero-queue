class CreateSummonerTeams < ActiveRecord::Migration
  def change
    create_table :summoner_teams do |t|
    	t.belongs_to :team, index: true
    	t.belongs_to :summoner, index: true

      t.timestamps null: false
    end
  end
end
