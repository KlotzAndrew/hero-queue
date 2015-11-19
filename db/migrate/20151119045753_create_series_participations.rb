class CreateSeriesParticipations < ActiveRecord::Migration
  def change
    create_table :series_participations do |t|
    	t.integer :series_id, null: false
    	t.integer :summoner_id, null: false
    	t.integer :points

      t.timestamps null: false
    end
  end
end
