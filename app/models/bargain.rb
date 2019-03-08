class Bargain < ApplicationRecord
    def self.rule
        "出價大於0,最小且唯一的的人勝利"
    end

    def self.start(channel_id)
      Bargain.find_or_create_by(channel_id: channel_id).update(all_bid: [0])
    end

    def self.game_end(channel_id)
      game = Bargain.find_by(channel_id: channel_id)
      game.destroy
    end

    def self.check(channel_id, message)
      game = Bargain.find_by(channel_id: channel_id)
      if game.all_bid.find {|n| n == message}.nil? 
        p game.all_bid.min
        p message
        if game.all_bid.min > message
          result = "恭喜您，您的出價 #{message} 元目前是最低價且唯一的那位喔"
        else
          not_uniq = game.all_bid.select {|n| game.all_bid.count(n) > 1 }
          uniq_bid = game.all_bid - not_uniq
          uniq_bid << message
          x = uniq_bid.sort.index(message)
          #game.update(now_winner: user_name)
          result = "你目前是 #{message} 元這個價位唯一的出價者，但不是最低的那一位，比您低的還有 #{x} 位"
        end
      else
        result  = "您的出價 #{message} 元，跟人重複囉"
      end
      all_bid = game.all_bid << message
      game.update(all_bid: all_bid)
      result
    end
end
