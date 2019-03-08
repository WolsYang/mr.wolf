class CreateBargains < ActiveRecord::Migration[5.2]
  def change
    create_table :bargains do |t|
      t.string :now_winner
      t.text :all_bid, array: true, :default =>[]
      t.string  :channel_id

      t.timestamps
    end
  end
end
