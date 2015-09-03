class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
    	t.string :name
    	t.string :game
    	t.integer :total_players
    	t.integer :total_teams
    	t.string :start_date
    	t.string :location
    	t.string :facebook_url

      t.timestamps null: false
    end
  end
end
