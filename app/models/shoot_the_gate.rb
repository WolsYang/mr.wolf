class ShootTheGate < ApplicationRecord
    def self.rule
      "遊戲開始拉~~\"A\" ~ \"K\"分別對應 1 ~ 13 只看 數字 不看 花色 
      \n1.先輸入\"抽\"抽取 門柱牌
      \n2.再輸入\"射\"抽取 射門牌
      \n3.若 射門牌 數字介於 門柱牌 數字中間代表進球您就贏啦~
      \n輸入\"重抽\"換一副牌重新開始
      \n輸入\"小賭怡情\"來點小驚喜
      \n P.S. 記得先輸入\"抽\"抽取門柱，再輸入\"射\"抽取射門牌，直接射的話就只能用上一個人的門柱了QQ"	
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

  def self.shoot(received_text, channel_id, basic_bet = 10)
    game = ShootTheGate.find_or_create_by(channel_id: channel_id)
    bet = basic_bet
    if received_text =~ /^小賭怡情\d*/
      if received_text[4].nil?
        return "請輸入\"小賭怡情+玩家數量\"來開啟計算籌碼功能\n例如 有五位玩家就輸入 \"小賭怡情5\" ，\n獎金池就會等於 = 玩家數 5 * 10(系統預設底注)
        \n成功設定後可以輸入我賭+下注數字 例如 \"我賭20\" 代表抽一張牌並下注20\n若輸入 \"抽\" 或是 只輸入\"我賭\"則會使用 10(系統預設底注) 下注\n玩得開心:)"
      end
      players = received_text[4..5]
      stakes = basic_bet*players.to_i
      game.update(stakes: stakes, gambling: "Yes")
      return "目前玩家 " + players + " 位" +"\n獎金池：" + stakes.to_s
    end

    if received_text =~ /^我賭\d*/ && game.gambling == "Yes"
      bet = basic_bet if received_text[2].nil?
      return "獎金池沒了...請重新輸入\"小賭怡情\"設定" if game.stakes == 0
      (2...received_text.size).each do |n|
        unless received_text[n].match(%r{[0-9]|\s}).nil?
          bet = received_text[2..n]
        end
      end
      bet = game.stakes if bet.to_i > game.stakes #獎金池&最大注 
      bet = bet.to_i
      received_text = "射"
    end
     
    case received_text
      when  "重抽"
        poker = Poker.shuffle(1)
        game.update(cards: poker)
        return  "射龍門開始啦~~~~~~~~~~~~請輸入 \"抽\" 繼續"
      when "抽"
        return "您已經抽過門柱牌喔~\n請輸入 射 抽取射門牌" unless game.card1.nil?
        return "您已經抽過門柱牌喔~\n請輸入 射 抽取射門牌" unless game.card2.nil?
        card1 = game.cards.delete_at(0)
        game.update(card1: card1)
        number1 = ShootTheGate.to_number(card1)
        card2 = game.cards.delete_at(0)
        game.update(card2: card2)
        number2 = ShootTheGate.to_number(card2)
        now_cards = game.cards
        game.update(cards: now_cards)
        return "門柱==>" + card1 + card2
      when "射"
        return "您還沒有抽門柱牌喔~\n請輸入 抽 抽取門柱牌" if game.card1.nil?
        return "您還沒有抽門柱牌喔~\n請輸入 抽 抽取門柱牌" if game.card2.nil?
        puts game.cards.size
        puts game.card1
        puts game.card2
        return "沒牌囉請輸入\"重抽\"重新洗一付牌"if game.cards.size < 3
        card1 = game.card1
        game.card1 = nil
        number1 = ShootTheGate.to_number(card1)
        card2 = game.card2
        game.card2 = nil
        number2 = ShootTheGate.to_number(card2)
        card3 = game.cards.delete_at(0)
        user_number = ShootTheGate.to_number(card3)
        now_cards = game.cards
        game.update(cards: now_cards)
        if number2 > number1#門柱排序 case when條件需要照順序
          number2, number1 = number1, number2
        end

        case user_number
          when number2+1...number1-1 
            if game.gambling == "Yes"
              result = game.stakes - bet
              game.update(stakes: result)
              "您的牌" + card3 +" \n進啦進啦~~贏錢啦!!!" + "\n您贏" + bet.to_s + "\n目前獎金池" + result.to_s
            else
              "您的牌" + card3 +" \n進啦進啦~~!!!" + "您贏了" 
            end
          when number1, number2
            if game.gambling == "Yes"
              result = game.stakes + (bet*2)
              game.update(stakes: result)
              "您的牌" + card3 + " \n撞柱柱柱柱柱柱柱柱柱!!!!兩倍啦~"+ "\n您輸" + (bet*2).to_s + "\n目前獎金池" + +result.to_s
            else
              "您的牌" + card3 + " \n撞柱柱柱柱柱柱柱柱柱!!!!輸了QQ"
            end           
          else
          # 另一種玩法 門柱一樣 除了撞柱都贏
          #  if number1 == number2
          #    if game.gambling == "Yes"
          #      result = game.stakes - bet
          #      game.update(stakes: result)
          #      puts "賭博"
          #      card3 +" \n進啦進啦~~贏錢啦!!!" + "\n您贏" + bet.to_s + "\n目前獎金池" + result.to_s
          #    else
          #      puts user_number.to_s + "   user_number"
          #      card3 +" \n進啦進啦~~!!!" + "您贏了" 
          #    end
          #  else
              if game.gambling == "Yes"
                result = game.stakes + bet
                game.update(stakes: result)
                "您的牌" + card3 +" \n界外球 賠錢拉~~~"+ "\n您輸" + bet.to_s + "\n目前獎金池" + +result.to_s
              else
                "您的牌" + card3 +" \n界外球 您輸啦" 
              end            
          #  end
        end
      else
        return nil
    end
  end
end
