class ShootTheGate < ApplicationRecord
  def self.rule
    "遊戲開始拉~~\"A\" ~ \"K\"分別對應 1 ~ 13 只看 數字 不看 花色 
    \n1.先輸入\"抽\"抽取 門柱牌
    \n2.再輸入\"射\"抽取 射門牌
    \n3.若 射門牌 數字介於 門柱牌 數字中間代表進球您就贏啦~
    \n輸入\"重抽\"換一副牌重新開始
    \n輸入\"小賭怡情\"來點小驚喜
    \n P.S. 記得先輸入\"抽\"抽取門柱，再輸入\"射\"抽取射門牌"	
  end

  def self.to_number(symbol)
    case symbol[2]
      when "A";  1
      when "J"; 11
      when "Q"; 12
      when "K"; 13
      else
        number = symbol[2..3]
        number.to_i
    end
  end

  def self.shoot(received_text, channel_id, user_name, basic_bet = 10)
    game = ShootTheGate.find_or_create_by(channel_id: channel_id)
    bet = basic_bet
    puts game.card1
    puts game.card2
    puts "shooooooooooooooooooooooooooooooooooooooooot"
    if received_text == "結果"
      return ShootTheGate.gambling_result(game)
    end
    if received_text =~ /^小賭怡情\d*/
      if received_text[4].nil?
        return "請輸入\"小賭怡情+獎金池數字\"來開啟計算籌碼功能
        \n例如輸入 \"小賭怡情100\" ，
        \n獎金池就會等於 = 100
        \n成功設定後可以輸入關鍵字+下注數字 例如
        \n\"我賭20\" \"射20\" 代表抽一張牌並下注20
        \n若輸入 \"射\" 或是 只輸入\"我賭\"則會使用 10(系統預設底注) 下注
        \n如果抽出兩個門柱一樣，會多出\"上\" \"下\" 兩個關鍵字可以使用
        \n輸入\"結果\"來看目前有參與的玩家的勝負統計
        \n玩得開心 ^_^"
      end
      bet_pool = received_text[4..9]
      game.player_result[0][1] = game.player_result[0][1].to_i + bet_pool.to_i#記錄總獎金池
      game.update(stakes: bet_pool, gambling: "Yes")
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      puts bet_pool.class
      puts game.player_result[0][1].class
      puts game.player_result[0][2].class
      return "目前" +"獎金池：" + bet_pool.to_s
    end
    if received_text =~ /^我賭\d*/ && game.gambling == "Yes"
      bet = basic_bet if received_text[2].nil?
      return "獎金池沒了...請重新輸入\"小賭怡情\"設定" if game.stakes == 0
      (2...received_text.size).each do |n|
        bet = received_text[2..n] unless received_text[n].match(%r{[0-9]|\s}).nil?
      end
      bet = game.stakes if bet.to_i > game.stakes #獎金池&最大注 
      bet = bet.to_i
      received_text = "射"
    elsif received_text =~ /^[射上下][1-9]\d*/ && game.gambling == "Yes"
      bet = basic_bet if received_text[1].nil?
      return "獎金池沒了...請重新輸入\"小賭怡情\"設定" if game.stakes == 0
      (1...received_text.size).each do |n|
        bet = received_text[1..n] unless received_text[n].match(%r{[0-9]|\s}).nil?
      end
      bet = game.stakes if bet.to_i > game.stakes #獎金池&最大注 
      bet = bet.to_i
      received_text = "射"  
      received_text = received_text[1] if game.card1 == game.card2
    end
    case received_text
      when  "重抽"
        poker = Poker.shuffle(1)
        game.update(cards: poker)
        return  "射龍門開始啦~~~~~~~~~~~~請輸入 \"抽\" 繼續"
      when "抽"
        return "沒牌囉\n請輸入\"重抽\"重新洗一付牌"if game.cards.size < 3
        return "您已經抽過門柱牌喔~\n請輸入 射 抽取射門牌" unless game.card1.nil? || game.card2.nil?
        card1 = game.cards.delete_at(0)
        number1 = ShootTheGate.to_number(card1)
        card2 = game.cards.delete_at(0)
        number2 = ShootTheGate.to_number(card2)
        now_cards = game.cards
        game.update(cards: now_cards, card1: card1, card2: card2)
        puts game.card1
        puts game.card2
        game = ShootTheGate.find_or_create_by(channel_id: channel_id)
        puts game.card1
        puts game.card2
        puts "抽......................................."
        return "門柱==>" + card1 + card2 + "哇 門柱一樣 請輸入 \"上\" 或 \"下\"來猜測下張牌的落點 " if card1 == card2
        return "門柱==>" + card1 + card2
      when /^[射上下]/
        return "沒牌囉\n請輸入\"重抽\"重新洗一付牌"if game.cards.size < 1
        return ShootTheGate.shoot_result(received_text, game, bet, user_name)
    end
  end

  def self.shoot_result(received_text, game, bet, user_name)
    return "您還沒有抽門柱牌喔~\n請輸入 抽 抽取門柱牌" if game.card1.nil? || game.card2.nil?
    card1 = game.card1
    number1 = ShootTheGate.to_number(card1)
    card2 = game.card2
    number2 = ShootTheGate.to_number(card2)
    card3 = game.cards.delete_at(0)
    user_number = ShootTheGate.to_number(card3)
    if number2 > number1#門柱排序 case when條件需要照順序
      number2, number1 = number1, number2
    end
    if game.gambling == "Yes" && user_number == number2 || user_number == number1  
      puts "撞住"
      received_text = ""
      result_text = ShootTheGate.reply_text(game, user_name, card3, "lose", bet, 2)
      puts result_text
      puts "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo"
    elsif user_number == number2 || user_number == number1
      result_text = ShootTheGate.reply_text(game, user_name, card3, "lose", bet, 2)
    end  
    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
    puts result_text
    case received_text
      when "射"
        puts "22222222222222222222222222222222222222222222222222222222222222"
        puts game.card1
        puts game.card2
        puts card3
        puts bet
        if user_number > number2 && user_number < number1 && game.gambling == "Yes"
          puts "3333333333333333333333333333333333333333333333333333333333333333333333333333"
          puts game.card1
          puts game.card2
          puts card3
          puts bet
          result_text = ShootTheGate.reply_text(game, user_name, card3, "win", bet)
        elsif user_number > number2 && user_number < number1
          puts "3333333333333333333333333333333333333333333333333333333333333333333333333333"
          puts game.card1
          puts game.card2
          puts card3
          puts bet
          result_text = ShootTheGate.reply_text(game, user_name, card3, "win")
        elsif game.gambling == "Yes"
          puts "3333333333333333333333333333333333333333333333333333333333333333333333333333"
          puts game.card1
          puts game.card2
          puts card3
          puts bet
          result_text = ShootTheGate.reply_text(game, user_name, card3, "lose", bet)
        else
          puts "3333333333333333333333333333333333333333333333333333333333333333333333333333"
          puts game.card1
          puts game.card2
          puts card3
          puts bet
          result_text = ShootTheGate.reply_text(game, user_name, card3, "lose")
        end
      when "上"  
        if user_number > number2 && game.gambling == "Yes"
          result_text = ShootTheGate.reply_text(game, user_name, card3, "win", bet)
        elsif user_number > number2
          result_text = ShootTheGate.reply_text(game, user_name, card3, "win")
        elsif game.gambling == "Yes"
          result_text = ShootTheGate.reply_text(game, user_name, card3, "lose", bet)
        else
          result_text = ShootTheGate.reply_text(game, user_name, card3, "lose")
        end
      when "下"
        if user_number < number2 && game.gambling == "Yes"
          result_text = ShootTheGate.reply_text(game, user_name, card3, "win", bet)
        elsif user_number > number2
          result_text = ShootTheGate.reply_text(game, user_name, card3, "win")
        elsif game.gambling == "Yes"
          result_text = ShootTheGate.reply_text(game, user_name, card3, "lose", bet)
        else
          result_text = ShootTheGate.reply_text(game, user_name, card3, "lose")
        end
    end
    puts "??????????????????????????????????????????????????????"
    puts result_text
    result_text
  end

  def self.record_player_result(game, bet, user_name)
    game.player_result[0][2] = game.player_result[0][2].to_i + 1  #紀錄總局數
    player_result_index = game.player_result.find_index{|i| i[0] == user_name}
    if player_result_index.nil?
      player_result =[user_name, bet, 1] #[名子,勝負,射了幾局]
      game.player_result << player_result
    else
      i = game.player_result[player_result_index]
      player_result = [i[0], i[1].to_i-bet, i[2].to_i+1]
      game.player_result[player_result_index] = player_result
    end
    game.player_result
  end

  def self.gambling_result(game)
    puts game.player_result[0][1].to_i
    puts game.player_result[0][2].to_i
    message=""
    if game.player_result.nil?
      message = "目前沒有人耶..."
    else 
      (1...game.player_result.size).each do |n| #game.player_result第一個直是預設的不用印
        n = game.player_result[n]
        bet_rate = (game.player_result[0][1].to_i * n[2].to_i) /game.player_result[0][2].to_i
        puts game.player_result[0][1].to_i
        puts game.player_result[0][2].to_i
        puts n[2].to_i
        message +=  "[玩家] : " + n[0] + " [籌碼數] : " + n[1] + " [參與局數] : " + n[2] + "[需貢獻獎金池] : " + bet_rate.to_s + "\n" 
      end
    end
    "需貢獻獎金池 = (總獎金池/總局數)*玩家參與局數 \n" + "[總獎金池] : " + game.player_result[0][1] + "[總局數] : "+ game.player_result[0][2] +"\n" + message
  end

  def self.reply_text(game, user_name, card3, win_or_lose, bet = nil, rate = nil) #rate有值代表撞柱
    message=""
    puts "11111111111111111111111111111111111111111111111111"
    puts game.card1
    puts game.card2
    bet = bet*2 unless rate.nil?
    result = nil
    player_result= ShootTheGate.record_player_result(game, bet, user_name)
    now_cards = game.cards #因為卡已經被抽起起來了 需要更新
    puts card3
    puts bet
    puts result
    if win_or_lose == "win" #玩家沒有贏兩倍這選項
      result = game.stakes - bet
      if bet.nil?
        message = "\n您的牌=>" + card3 + "\n恭喜猜對了~~您贏了"
      elsif rate.nil?
        message = "\n您的牌 =>" + card3 + "\n進啦進啦~~贏錢啦!!!" + "\n您贏 : " + bet.to_s + "\n目前獎金池 : " + result.to_s
      end
    else win_or_lose == "lose" 
      result = game.stakes + bet
      if bet.nil?
        message = "\n您的牌=>" + card3 + "\nQ_Q 沒射進 您輸了"
      elsif rate.nil?
        message = "\n您的牌=>" + card3 + "\nQ_Q 沒射進 賠錢拉~~~"+ "\n您輸 : " + bet.to_s + "\n目前獎金池 : " + +result.to_s 
      else
        message = "\n您的牌=>" + card3 + "\n撞柱柱柱柱柱柱柱柱柱!!!!兩倍啦~" + "\n您輸 : " + bet.to_s + "\n目前獎金池 : " + result.to_s
      end
    end
    puts "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm"
    puts game.card1
    puts message.class
    puts message
    message = "[門柱]==>" + game.card1 + game.card2 + message
    game.update(stakes: result, player_result: player_result, cards: now_cards ,card1: nil, card2: nil )
    return message
  end
end
