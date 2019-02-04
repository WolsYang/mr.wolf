class CreateBombs < ActiveRecord::Migration[5.2]
  def change
    create_table :bombs do |t|
      t.integer :now_min, :default => 0
      t.integer :now_max
      t.integer :user_number, :default => 0
      t.integer :code
      t.string  :channel_id

      t.timestamps
    end
  end
end
