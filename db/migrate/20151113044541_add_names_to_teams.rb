class AddNamesToTeams < ActiveRecord::Migration
  def change
  	add_column :teams, :name, :string
  	add_column :teams, :position, :integer
  end
end
