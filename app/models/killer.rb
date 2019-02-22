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
    #遊戲開始的設定
    def self.start_n_rule(channel_id)
        rounds = 1
		players = REDIS.lrange(channel_id,0,-1)
		REDIS.del(channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        killer = players.shuffle[1]
		kill.update(players: players, killer: killer , game_begin: false, round: rounds)
        text = "遊戲開始啦 ~ 參與的玩家有#{players.size}位
            \n1.接下來將會從玩家中隨機挑出一名殺手
            \n2.殺手在天黑時選取欲殺害的玩家
            \n3.天亮時其餘玩家可投票誰是殺手，得票最高的玩家會被處決
            \n4.如果最後僅剩一位玩，殺手就贏得這個遊戲囉～"
            p channel_id + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" 
            p killer[11...44] + "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
        reply_text = Killer.reply_message(text, Killer.player_list(channel_id))
        p reply_text 
        p "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        p Killer.player_list(channel_id).class
        p Killer.reply_message("你是殺手,你唯一且必須的任務就是殺光所有生還者").class
        p killer
        p killer[11...44]
        ChatbotController.new.push_to_line(killer[11...44], "你是殺手,你唯一且必須的任務就是殺光所有生還者")
        ChatbotController.new.push_to_line(channel_id, text, Killer.player_list(channel_id))
    end
    #合併LINE USER ID 和使用者顯示名稱 + 並加上 channel_id 前10碼 避免用戶同時在其他地方玩遊戲
    def self.to_gameid(user_id, user_name, channel_id)
        #REDIS = Redis.new
        player = ";" + channel_id[0...10] + user_id + user_name + ";"#因為編碼會錯誤 所以用兩個分號刮起來,然後就可以解析了
        player.to_s
    end

    def self.game_end(channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        Channel.find_by(channel_id: channel_id).update(now_gaming: "No")
        for_counting = "for_counting" + channel_id.to_s
        REDIS.del(for_counting , 0)
        kill.destroy
    end

    def self.rounds(player, channel_id, has_vote)
        kill = Killer.find_by(channel_id: channel_id)
        day_or_night = kill.round % 2 #night:1 , day:0
        if day_or_night == 1 && player == kill.killer
            for_counting = "for_counting" + channel_id.to_s
            REDIS.set("for_counting", 0)#每回合每人投票數的比較基準值，遊戲回合夜晚時歸0
            kill.players.each {|n| REDIS.set(player, 0)}#夜晚玩家投票數值歸0
            Killer.killer_chooise(has_vote, channel_id)
        elsif day_or_night == 0 
            if REDIS.get(jid).nil?#第一個投票時開始計算
                job = KillRoundWorker.set(wait: 20.minutes).perform_later(channel_id)#超過20分鐘沒人投票
                jid = job.provider_job_id 
                REDIS.set(jid, jid)
            end
            Killer.check_vote(player, channel_id, has_vote)
            replytext = Killer.vote(channel_id) if REDIS.get(channel_id) == kill.players.size #都投完票才開始計算結果 減輕資料庫負擔
            # menu + reply_text
        elsif kill.players.size <= 2
            Killer.game_end(channel_id)
            reply_text = "最後的玩家已成為了待宰羔羊，殺手贏了．．．"
            Killer.reply_message(reply_text)
        end

    end
    #殺手選擇殺的人
    def self.killer_chooise(has_vote, channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        #if has_vote == kill.killer
        #    reply_text = "生命誠可貴，想一想您可以不必自殺，再挑一個吧"
        #else
            n = kill.players.index(has_vote)#測試自己殺自己用
            kill.players.delete_at(n)#測試自己殺自己用
            #kill.players.delete(has_vote)
            kill.update(players: kill.players, round: kill.round+1)
            REDIS.del(has_vote)#刪除被殺玩家
            reply_text = "天亮了...玩家" + has_vote[44...-1] + "已經被殺手殺死"
            Killer.reply_message(reply_text)
        #end
    end
    #檢查是否投果票和投誰?
    def self.check_vote(has_vote, channel_id, player)
        kill = Killer.find_by(channel_id: channel_id)
        players = kill.players #不用redis 避免佔據記憶體或伺服器關機資料不見
        unless players.index(player).nil? #投票玩家是否有參與遊戲
            return if  REDIS.get(player) < 1000 #超過1000代表已經投票
            REDIS.set(player, 1000) 
            REDIS.incr(has_vote)#被投票玩家投票數+1
            REDIS.incr(channel_id)#紀錄已投票玩家數量
        end
    end
    #投票處決
    def self.vote(channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        kill.update(players: kill.players, round: kill.round+1)
        players = kill.players 
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
            Killer.game_end(channel_id)
            reply_text = "天黑了" + vote_result[44...-1] + "是殺手" +"\n殺手已被處死，玩家勝利啦！\n遊戲結束"
            Killer.reply_message(reply_text)
        elsif vote_result == "no body die"
            reply_text = "天黑了 最高投票超過1位...沒人死亡\n殺手請選擇下一位受害者....`"
            Killer.reply_message(reply_text, player_list)
        else         
            players.delete(vote_result)
            kill.update(players: players)
            reply_text = "天黑了 玩家" + vote_result[44...-1] + "已被表決處死"+ "\n殺手依然逍遙法外\n殺手請選擇下一位受害者...."
            Killer.reply_message(reply_text, player_list)
        end
    end
     #剩餘玩家名單按鈕
    def self.player_list(channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        column_number = (kill.players.size/3.0).ceil 
        columns = [0...column_number]
        actions = [0...column_number*3] #line要求每個按鈕菜單數量都一樣
        (0...column_number*3).each do |n|
            player = ( kill.players[n].nil? ) ? "沒有這個人" : kill.players[n] #三元運算
            player_name = ( kill.players[n].nil? ) ? "沒有這個人" : kill.players[n][44...-1]#三元運算
          actions[n] = {
                "type": "postback",
                "label": player_name,
                "data": player
            }
        end
        (0...column_number).each do |n|
          columns[n] = {
            "title": "倖存者名單",
            "text": "第 #{n.to_s} 頁",
            "actions": actions[n..n+2]
          }
        end
        message = {
            "type": "template",
            "altText": "名單",
            "template": {
            "type": "carousel",
            "columns": columns
            }
        }
        return message#.to_json
    end

    def self.reply_message(reply_text, player_list = nil)
        if player_list.nil?
            p "有有有有有有有有有有有有有有有有有有有有有有有有有有有有"
            message = {
			    type: 'text',
			    text: reply_text
            }
        else  
            p "無無無無無無無無無無無無無無無無無無無無無無無無無無無無無無無無"
            message = {
			    type: 'text',
			    text: reply_text
            }, player_list
        end
    end
end
