class RemoveGameColumAndAddGameStatus < ActiveRecord::Migration[5.2]
  def change
  	  remove_column :channels, :bomb
  	remove_column :channels, :dice
  	remove_column :channels, :porker
  	remove_column :channels, :wolf
  	add_column :channels, :now_gaming, :string , :default => "no"
  end
end
