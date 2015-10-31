class AddTournamentTeamApproval < ActiveRecord::Migration
  def change
  	add_column :tournaments, :teams_approved, :boolean, default: false
  end
end
