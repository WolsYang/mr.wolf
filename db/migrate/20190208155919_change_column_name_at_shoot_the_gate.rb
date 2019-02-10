class ChangeColumnNameAtShootTheGate < ActiveRecord::Migration[5.2]
  def change
    rename_column :shoot_the_gates, :now_max, :card1
    rename_column :shoot_the_gates, :now_min, :card2
  end
end
