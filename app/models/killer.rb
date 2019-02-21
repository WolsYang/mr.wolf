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

    def self.start_n_rule
        text = "遊戲開始啦 ~ 
            \n1.接下來將會從玩家中隨機挑出一名殺手
            \n2.殺手在天黑時選取欲殺害的玩家
            \n3.天亮時其餘玩家可投票誰是殺手，得票最高的玩家會被處決
            \n4.如果最後僅剩一位玩，殺手就贏得這個遊戲囉～"
    end

    def self.to_gameid(user_id, user_name)
        #REDIS = Redis.new
        player = ";" + user_id + user_name + ";"#因為編碼會錯誤 所以用兩個分號刮起來,然後就可以解析了
        player.to_s
    end

    def self.rounds(player, channel_id, has_vote)
        kill = Killer.find_by(channel_id: channel_id)
        rounds = kill.round +1
        kill.update(round: rounds)
        day_or_night = rounds % 2 #night:1 , day:0
        if day_or_night == 1 && player == kill.killer
            REDIS.set("for_counting", 0)#每回合頭投票的比較基準值，遊戲回合夜晚時歸０
            Killer.chooise(has_vote, channel_id)
        elsif day_or_night == 0 && kill.players.find{|i| i[1...34] == player} != nil
            Killer.is_vote(player, channel_id, has_vote)
            Killer.vote(channel_id)
        elsif kill.players.size <= 2
            kill.destroy
            Channel.find_by(channel_id: channel_id).update(now_gaming: "No")
            reply_text = "最後的玩家已成為了待宰羔羊，殺手贏了．．．"
        end

    end

    def self.chooise(has_vote, channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        if has_vote == kill.killer
            reply_text = "生命誠可貴，想一想您可以不必自殺，再挑一個吧"
        else
            kill.players.delete(has_vote)
            kill.update(players: kill.players)
            reply_text = "天亮了...玩家" + has_vote[33..-1] + "已經被殺手殺死"
        end
    end

    def self.is_vote(has_vote, channel_id, player)
        kill = Killer.find_by(channel_id: channel_id)
        #REDIS = Redis.new
        players = kill.players 
        if REDIS.get(player).nil?
            REDIS.set(player, 1000)#1000代表已經投票
            REDIS.incr(has_vote)
            REDIS.incr(channel_id)
        end
    end

    def self.vote(channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        #REDIS = Redis.new
        players = kill.players 
        if REDIS.get(channel_id) == kill.players.size
            #把REDIS規0還要把排程刪除
            #統計得票結果,並歸0
            (0...players.size).each do |n|
                if REDIS.get("for_counting").to_i < REDIS.get(players(n)).to_i
                    max_vote = REDIS.get(players(n))
                    REDIS.set("for_counting", max_vote)
                    vote_result = players[n]
                elsif REDIS.get("for_counting").to_i = REDIS.get(players(n)).to_i
                    same_vote = REDIS.get(players(n))
                    vote_result = "no body die"
                end
                REDIS.set(players[n], 0)
            end
            if vote_result == kill.killer
                kill.destroy
                Channel.find_by(channel_id: channel_id).update(now_gaming: "No")
                vote_result[34...-1] + "是殺手" +"\n殺手已被處死，玩家勝利啦！\n遊戲結束"
            elsif vote_result == "no body die"
                "最高投票超過1位...沒人死亡"
            else         
                players.delete(player)
                kill.update(players: vote_result )
                "玩家" + vote_result[34...-1] + "已被表決處死"+ "\n殺手依然逍遙法外"
            end
        end
    end
     
    def self.player_list(channel_id, reply_text)
        kill = Killer.find_by(channel_id: channel_id)
        column_number = (kill.players.size/3.0).ceil 
        columns = [0...column_number]
        actions = [0...column_number*3] #line要求每個按鈕菜單數量都一樣
        (0...column_number*3).each do |n|
            player = ( kill.players[n].nil? ) ? "沒有這個人" : kill.players[n] #三元運算
            player_name = ( kill.players[n].nil? ) "沒有這個人" : kill.players[n][33..-1]#三元運算
          actions[n] = {
                "type": "postback",
                "label": player_name,
                "data": player
            }
        end
        (0...column_number).each do |n|
          columns[n] = {
            "title": "kill",
            "text": "第 "+ n.to_s +" 頁",
            "actions": actions[n..n+2]
          }
        end
        {
            "type": "template",
            "altText": "this is a carousel template",
            "template": {
            "type": "carousel",
            "columns": columns
            }
        }
        return message.to_jason
    end
end
