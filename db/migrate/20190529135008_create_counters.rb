class CreateCounters < ActiveRecord::Migration[5.2]
  def change
    create_table :counters do |t|
      t.string :channel_id
      t.integer :now_wait
      
      t.timestamps
    end
  end
end
