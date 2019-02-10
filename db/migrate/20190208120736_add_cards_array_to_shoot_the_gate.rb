class AddCardsArrayToShootTheGate < ActiveRecord::Migration[5.2]
  def change
	add_column :shoot_the_gates, :cards, :text, default: [].to_yaml#, array:true
  end
end
