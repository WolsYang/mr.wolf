class AddEachOneBidToShootTheGate < ActiveRecord::Migration[5.2]
  def change
    add_column :shoot_the_gates, :player_result, :text, array: true
  end
end
