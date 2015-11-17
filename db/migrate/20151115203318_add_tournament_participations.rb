class AddTournamentParticipations < ActiveRecord::Migration
  def change
  	add_column :summoner_teams, :ticket_id, :integer
    add_column :summoner_teams, :tournament_id, :integer
    add_column :summoner_teams, :duo_id, :integer
    add_column :summoner_teams, :duo_approved, :boolean, default: false

    rename_table :summoner_teams, :tournament_participations
  end
end
