class Killer < ApplicationRecord
    def self.rule
        "遊戲開始啦 ~ 
        \n1.接下來將會從玩家中隨機挑出一名殺手，其餘玩家為平民
        \n2.殺手在天黑時選取欲殺害的平民
        \n3.天亮時存活的玩家包含殺手有２０分鐘可以討論並投票誰是兇手，死掉的玩家也能參與討論，但不能投票
        \n4.得票最高的玩家會被處決，若有兩人得票數(不包含0票)一樣則沒有人死亡
        \n5.如果最後僅剩一位平民，殺手就贏得這個遊戲囉～
        \n＊＊＊請要參與的玩家於1分鐘內輸入 +1 ＊＊＊
        \n＊＊＊1分鐘後遊戲正式開始＊＊＊ "
    end

    def self.to_gameid(user_id, user_name)
        redis = Redis.new
        player = user_id + user_name
    end

    def self.round(player, channel_id, has_vote)
        kill = Killer.find_by(channel_id: channel_id)
        round = kill.round +1
        kill.update(round: round)
        day_or_night = round % 2 #night:1 , day:0
        if day_or_night == 1 && player == kill.killer
            redis.set("for_counting", 0)#每回合頭投票的比較基準值，遊戲回合夜晚時歸０
            Killer.chooise(has_vote, channel_id)
        elsif day_or_night == 0 && kill.players.find{|i| i[0...33] == player} != nil
            Killer.is_vote(player, channel_id, has_vote)
            Killer.vote(channel_id)
        elsif kill.players.size <= 2
            kill.destroy
            Channel.find_by(channel_id: channel_id).update(now_gaming: "No")
            "最後的玩家已成為了待宰羔羊，殺手贏了．．．"
        end
    end

    def self.chooise(has_vote, channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        if has_vote ==  kill.killer
            "生命誠可貴，想一想您可以不必自殺，再挑一個吧"
        else
            kill.players.delete(has_vote)
            kill.update(players: kill.players)
            "天亮了...玩家" + has_vote[33..-1] + "已經被殺手殺死"
        end
    end

    def self.is_vote(has_vote, channel_id, player)
        kill = Killer.find_by(channel_id: channel_id)
        redis = Redis.new
        players = kill.players 
        if redis.get(player).nil?
            redis.set(player, 1000)#1000代表已經投票
            redis.incr(has_vote)
            redis.incr(channel_id)
        end
    end

    def self.vote(channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        redis = Redis.new
        players = kill.players 
        if redis.get(channel_id) == kill.players.size
            #把redis規0還要把排程刪除
            #統計得票結果,並歸0
            (0...players.size).each do |n|
                if redis.get("for_counting").to_i < redis.get(players(n)).to_i
                    max_vote = redis.get(players(n))
                    redis.set("for_counting", max_vote)
                    vote_result = players[n]
                elsif redis.get("for_counting").to_i = redis.get(players(n)).to_i
                    same_vote = redis.get(players(n))
                    vote_result = "no body die"
                end
                redis.set(players[n], 0)
            end
            if vote_result == kill.killer
                kill.destroy
                Channel.find_by(channel_id: channel_id).update(now_gaming: "No")
                vote_result[33..-1] + "是殺手" +"\n殺手已被處死，玩家勝利啦！\n遊戲結束"
            elsif vote_result = "no body die"
                "最高投票超過1位...沒人死亡"
            else         
                players.delete(player)
                kill.update(players: vote_result )
                "玩家" + vote_result[33..-1] + "已被表決處死"+ "\n殺手依然逍遙法外"
            end
        end
    end

    def self.columns(channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        columns = []
        column_number = (kill.players.size/3.0).ceil 
        (0...column_number).each do |n|
          columns[n] = {
            "title": "kill",
            "text": "number"+ n.to_s,
            "actions": action(n, channel_id)
          }
        end
        return columns
      end
    
      def self.action(column_number, channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        actions =  []
        now_number = (3 * (column_number))
        (0...3).each do |n|
            kill.players[now_number + n][33..-1] =  "nobody" if kill.players[now_number + n][33..-1].nil?
            kill.players[now_number + n] = "nobody" if kill.players[now_number + n].nil?
          actions[n] = {
                "type": "postback",
                "label": kill.players[now_number + n][33..-1],
                "data": kill.players[now_number + n]
            }
        end
        return actions
      end


end
