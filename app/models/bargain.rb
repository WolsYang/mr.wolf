class Bargain < ApplicationRecord
    def self.rule
        "請輸入純數字出價，例如　3
        \n接下來系統會回覆您的出價目前的狀態
        \n出價大於0,最小且唯一的的人勝利
        \n 2分鐘後系統會高知誰贏囉~"
    end

    def self.start(channel_id)
      bargain = Bargain.find_or_create_by(channel_id: channel_id)
      bargain.update(all_bid: [99999999]) if bargain.all_bid.empty? #api模式 一進入頁面就初始化
    end

    def self.game_end(channel_id)
      game = Bargain.find_by(channel_id: channel_id)
      game.destroy
      Channel.find_by(channel_id: channel_id).update(now_gaming: "no")
    end

    def self.check(channel_id, message, user_name)
      game = Bargain.find_by(channel_id: channel_id)
      all_bid = game.all_bid.map(&:to_i)
      if all_bid.find {|n| n == message}.nil? 
        not_uniq = all_bid.select {|n| all_bid.count(n) > 1 }
        uniq_bid = all_bid - not_uniq
        if uniq_bid.min > message
          game.update(now_win_bid: message, now_winner: user_name)
          result = "恭喜您，您的出價 #{message} 元目前是最低價且唯一的那位喔"
        else
          uniq_bid << message
          x = uniq_bid.sort.index(message)    
          result = "你目前是 #{message} 元這個價位唯一的出價者，但不是最低的那一位，比您低的還有 #{x} 位"
        end
      else
        result  = "您的出價 #{message} 元，跟人重複囉"
      end
      bid = all_bid << message
      game.update(all_bid: bid)
      p game.all_bid
      result
    end

    def self.time_up(channel_id)
      game = Bargain.find_by(channel_id: channel_id)
      if game.now_winner.nil? || game.now_win_bid.nil?
        result = "沒人出價...流局囉"
      else
        result = "恭喜 #{game.now_winner} ,以 #{game.now_win_bid} 元得標"
      end
    end

    def self.now_win_bid(channel_id)
      game = Bargain.find_by(channel_id: channel_id)
      not_uniq = all_bid.select {|n| all_bid.count(n) > 1 }
      uniq_bid = all_bid - not_uniq
      uniq_bid.min
    end
end
