class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
    	t.string :name
    	t.string :game
    	t.integer :total_players
    	t.integer :total_teams
    	t.datetime :start_date
    	t.string :location_name
      t.string :location_url
      t.string :location_address
    	t.string :facebook_url

      t.timestamps null: false
    end
  end
end
