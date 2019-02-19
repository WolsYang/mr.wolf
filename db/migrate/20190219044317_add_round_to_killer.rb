class AddRoundToKiller < ActiveRecord::Migration[5.2]
  def change
    add_column :killers, :round, :integer 
  end
end
