class CreateSeriesParticipations < ActiveRecord::Migration
  def change
    create_table :series_participations do |t|

      t.timestamps null: false
    end
  end
end
