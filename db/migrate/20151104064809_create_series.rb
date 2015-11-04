class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
    	t.string :name, null: false

      t.timestamps null: false
    end

    add_column :tournaments, :series_id, :integer
  end
end
