class CreateShootTheGates < ActiveRecord::Migration[5.2]
  def change
    create_table :shoot_the_gates do |t|
      t.string :now_max
      t.string :now_min
      t.integer :stakes, :default => 0
	    t.string :gambling  , :default => "No"   
      t.string  :channel_id

      t.timestamps
    end
  end
end
