class CreateSummoners < ActiveRecord::Migration
  def change
    create_table :summoners do |t|
    	t.string :summonerName
    	t.string :summoner_ref
    	t.integer :summonerId
    	t.integer :summonerLevel
    	t.string :profileIconId

      t.timestamps null: false
    end
  end
end
