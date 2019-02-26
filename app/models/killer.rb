#放棄開發原版殺手遊戲 目前已知問題
#PUSH API 通知殺手功能是需要付費的
#Sidekiq的移除工作功能官方並沒有釋出
#照官方說明變相操作無法成功
#有額外插件可以做到這個功能但目前放棄開發故沒有測試這個功能
#LINE的滑動式按鈕有限制 故最多只能有10名玩家參與

class Killer < ApplicationRecord
    def self.rule
        "遊戲開始啦 ~ 
        \n1.接下來將會從玩家中隨機挑出一名兇手，其餘玩家為平民
        \n2.玩家可以透過TAG玩家送出來投票，例如　@王小明 \n 請注意 如果是XXX@王小明 或 @王小明XXX 這種有多餘的字的戲通都會判定投票失敗喔
        \n3.存活的玩家包含殺手有２０分鐘可以討論並投票誰是兇手，死掉的玩家也能參與討論，但不能投票\n 第一回合沒有任何線索，只能靠大家憑直覺猜啦
        \n4.當所有人都投完票以後，系統會提示誰的得票數最高，而殺手可以透過選擇按鈕來決定要不要殺這位玩家，若最高得票數有多位，殺手則可以一次選擇要不要殺全部
        \n5.若是最高得票數的是殺手則判定殺手輸了這場遊戲
        \n6.如果最後僅剩一位玩家，兇手就贏得這個遊戲囉～
        \n＊＊＊請要參與的玩家於1分鐘內輸入 +1 ＊＊＊
        \n＊＊＊1分鐘後遊戲正式開始＊＊＊ "
    end
    #遊戲開始的設定
    def self.start_n_rule(channel_id)
        if REDIS.lrange(channel_id,0,-1).size < 3
            text = "遊戲人數不足，遊戲無法啟動"
            Killer.game_end(channel_id)
        else
            rounds = 0
            players = REDIS.lrange(channel_id,0,-1)
            p players
            p "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
            REDIS.del(channel_id)
            kill = Killer.find_or_create_by(channel_id: channel_id)
            killer = players.shuffle[1]
            kill.update(players: players, killer: killer , game_begin: false, round: rounds)
            text = "遊戲開始啦 ~ 參與的玩家有#{players.size}位
                \n1.接下來將會從玩家中隨機挑出一名兇手
                \n2.玩家可以透過TAG玩家送出來投票，例如　@王小明 \n 請注意 如果是XXX@王小明 或 @王小明XXX 這種有多餘的字的戲通都會判定投票失敗喔
                \n3.當所有人都投完票以後，系統會提示誰的得票數最高，而殺手可以透過選擇按鈕來決定要不要殺這位玩家，若最高得票數有多位，殺手則可以一次選擇要不要殺全部
                \n4.若最高得票數有兩位則兩位都會死亡，若是最高得票數的是殺手則判定殺手輸了這場遊戲
                \n5.如果最後僅剩一位玩家，殺手就贏得這個遊戲囉～"
            ChatbotController.new.push_to_line(killer[11...44], "你是殺手,你唯一且必須的任務就是殺光所有生還者")
        end
        ChatbotController.new.push_to_line(channel_id, text)
    end
    #合併LINE USER ID 和使用者顯示名稱 + 並加上 channel_id 前10碼 避免用戶同時在其他地方玩遊戲
    def self.to_gameid(user_id, user_name, channel_id)
        #REDIS = Redis.new
        player = ";" + channel_id[0...10] + user_id + user_name + ";"#因為編碼會錯誤 所以用兩個分號刮起來,然後就可以解析了
        player.to_s
    end

    def self.game_end(channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        Channel.find_by(channel_id: channel_id).update(now_gaming: "no")
        kill.players.each {|i| p i} 
        kill.players.each {|i| REDIS.del(i)}
        REDIS.del(channel_id)
        REDIS.del("jid"+channel_id)
        kill.destroy
    end

    def self.rounds(player, channel_id, has_vote = nil)
        p "roundsroundsroundsroundsroundsroundsroundsroundsroundsroundsroundsroundsroundsroundsroundsroundsrounds"
        p REDIS.get(channel_id) #unless REDIS.get(channel_id).nil?
        kill = Killer.find_by(channel_id: channel_id)
        p kill.players.size #unless kill.players.size.nil?
        p "daydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydaydayday"
        p kill.round
        day_or_night = kill.round % 2 #night:1 , day:0
        voted_player = kill.players.detect{|i| i[44...-1] == has_vote}
        if day_or_night == 1 && player == kill.killer
            Killer.killer_chooise(voted_player, channel_id)
        elsif day_or_night == 0 
            p "票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票票"
            if REDIS.get("jid"+channel_id).nil?#第一個投票時開始計算
                p "計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時計時"
                job = KillRoundWorker.set(wait: 1.minutes).perform_later(channel_id, player)#超過20分鐘沒人投票
                jid = job.provider_job_id 
                REDIS.set("jid"+channel_id, jid)
            end
            result = Killer.check_vote(player, channel_id, voted_player)
            p REDIS.get(player).to_i
            p "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
            replytext = Killer.vote(channel_id) if REDIS.get(channel_id) == kill.players.size #都投完票才開始計算結果 減輕資料庫負擔
            # menu + reply_text
        elsif kill.players.size <= 2
            Killer.game_end(channel_id)
            reply_text = "最後的玩家已成為了待宰羔羊，殺手贏了．．．"
            Killer.reply_message(reply_text)
        end

    end
    #殺手選擇殺的人
    def self.killer_chooise(vote_result, channel_id)
        kill = Killer.find_by(channel_id: channel_id)
        #if voted_player == kill.killer
        #    reply_text = "生命誠可貴，想一想您可以不必自殺，再挑一個吧"
        #else          
            # REDIS.del(voted_player)#刪除被殺玩家
        if vote_result == "no"
            reply_text = "殺手放了條生路"
            kill.update(round: kill.round+1)
        else
            players = kill.players - vote_result 
            (0...vote_result).each do |n|
                n = kill.players.index(vote_result[n])#測試自己殺自己用
                kill.players.delete_at(n)#測試自己殺自己用
                died_player = vote_result[n][44...-1].to_s + " "
            end
        kill.update(players: players, round: kill.round+1) 
        reply_text = "天亮了...玩家" + died_player + "已經被殺手殺死"
        end
        Killer.reply_message(reply_text)
        #end
    end
    #檢查是否投果票和投誰?
    def self.check_vote(voted_player, channel_id, player)
        p "check_votecheck_votecheck_votecheck_votecheck_votecheck_votecheck_votecheck_votecheck_votecheck_votecheck_votecheck_votecheck_votecheck_vote"
        kill = Killer.find_by(channel_id: channel_id)
        players = kill.players #不用redis 避免佔據記憶體或伺服器關機資料不見
        unless players.index(player).nil? #投票玩家是否有參與遊戲
            if REDIS.get(player).to_i < 1000 #超過1000代表已經投票
                REDIS.incr(voted_player)#被投票玩家投票數+1
                REDIS.incr(channel_id)#紀錄已投票玩家數量
                REDIS.incrby(player, 1000)
            end
        end
    end
    #投票處決
    def self.vote(channel_id)
        p "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
        kill = Killer.find_or_create_by(channel_id: channel_id)
        players = kill.players
        p players
        p ">>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<"
        kill.update(round: kill.round+1)
        max_vote = 0 
        same_vote = 0
        REDIS.del("jid"+channel_id)#取消排程工作
        vote_result = []
        same_vote_result = []
        #Sidekiq::Status.unschedule job_identifier
        #把REDIS規0還要把排程刪除
        #統計得票結果,並歸0
        (0...players.size).each do |n|
            p players[n]
            player_number = REDIS.get(players[n]).to_i
            player_vote_number = player_number -1000 if player_number > 1000
            if max_vote < player_number
                max_vote = player_number
                same_vote_result = []
                vote_result = []
                vote_result << players[n]
            elsif max_vote == player_number
                same_vote_result << players[n]
            end
            REDIS.set(players[n], 0)#投票數歸零
        end
        vote_result += same_vote_result
        if vote_result == kill.killer
            Killer.game_end(channel_id)
            reply_text =  vote_result[44...-1] + "是兇手" +"\n兇手已被處死，玩家勝利啦！\n遊戲結束"
            Killer.reply_message(reply_text)
        else
            p "結果結果結果結果結果結果結果結果結果結果結果結果結果結果結果結果結果結果結果結果"
            died_player = ""
            (0...vote_result.size).each do |n|
                died_player = vote_result[n][44...-1].to_s + " "
            end
            text = "玩家" + died_player +"已被表決處死 \n但他不是兇手...真正的凶手可以選擇要不要殺他滅口"
            replay_text = Killer.reply_message(text, "confirm", vote_result)
            ChatbotController.new.push_to_line(channel_id, replay_text, "kill")
        end
    end

    def self.reply_message(reply_text, confirm = nil, vote_result = nil)
        if confirm.nil?
        message = {
            type: 'text',
            text: reply_text
        }
        #elsif player_list.nil?
        #message = {
        #    type: 'text',
        #    text: reply_text
        #}
        else  
            message = {
			    type: 'text',
			    text: reply_text
            },
            {
                "type": "template",
                "altText": "兇手的選擇",
                "template": {
                    "type": "confirm",
                    "text": "兇手大人,請您選一個吧",
                    "actions": [
                        {
                          "type": "postback",
                          "label": "滅口",
                          "data": vote_result.to_s
                        },
                        {
                          "type": "postback",
                          "label": "放他條生路",
                          "data": "no"
                        }
                    ]
                }
              }
        end
    end

     #剩餘玩家名單按鈕
    def self.player_list(channel_id)
        #line 要求 每個選單的3個action要長一樣 意思是每個 columns的actions[n..n+2]都一樣 所以這個功能目前是寫錯的  但英為沒有作用了 暫不修改也不刪除
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
            p actions[n]
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

end
