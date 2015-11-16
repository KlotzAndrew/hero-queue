class CreateTournamentParticipations < ActiveRecord::Migration
  def change
    create_table :tournament_participations do |t|
    	t.integer :tournament_id
    	t.integer :summoner_id
    	t.integer :duo_id
    	t.boolean :duo_approved, default: false

      t.timestamps null: false
    end
  end
end
