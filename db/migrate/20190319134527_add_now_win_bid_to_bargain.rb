class AddNowWinBidToBargain < ActiveRecord::Migration[5.2]
  def change
    add_column :bargains, :now_win_bid, :integer
  end
end
