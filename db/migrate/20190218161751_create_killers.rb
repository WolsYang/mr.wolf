class CreateKillers < ActiveRecord::Migration[5.2]
  def change
    create_table :killers do |t|
      t.string :killer
      t.text :players, array: true, :default =>[]
	    t.boolean :game_begin , :default => false   
      t.string  :channel_id

      t.timestamps
    end
  end
end
