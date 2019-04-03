class ChangePlayerResultDefultInShootTheGate3 < ActiveRecord::Migration[5.2]
  def change
    change_column_default :shoot_the_gates, :player_result, [["0", 0, 0]]
  end
end
