class CreateBombs < ActiveRecord::Migration[5.2]
  def change
  	remove_column :channels, :bomb
  	remove_column :channels, :dice
  	remove_column :channels, :porker
  	remove_column :channels, :wolf
  	add_column :channels, :now_gaming, :string , :default => "no"

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
