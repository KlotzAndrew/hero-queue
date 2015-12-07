class TourCancelFlag < ActiveRecord::Migration
  def change
    add_column :tournaments, :canceled, :boolean, default: false
  end
end
