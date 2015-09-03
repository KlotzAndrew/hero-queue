class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
    	t.integer :summoner_id
    	t.integer :tournament_id
    	t.string :contact_email
    	t.string :contact_first_name
    	t.string :contact_last_name
    	
    	t.text :notification_params
    	t.string :transaction_id
    	t.datetime	:purchased_at

      t.timestamps null: false
    end
  end
end
