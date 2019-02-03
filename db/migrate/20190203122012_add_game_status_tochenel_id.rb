class AddGameStatusTochenelId < ActiveRecord::Migration[5.2]
  def change
  	add_column :channels, :bomb, :boolean, :default => false
  	add_column :channels, :dice, :boolean, :default => false
  	add_column :channels, :porker, :boolean, :default => false
  	add_column :channels, :wolf, :boolean, :default => false
  end
end
