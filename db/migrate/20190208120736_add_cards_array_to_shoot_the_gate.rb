class AddCardsArrayToShootTheGate < ActiveRecord::Migration[5.2]
  def change
	add_column :shoot_the_gates, :cards, :text, array: true, default: []
  end
end
