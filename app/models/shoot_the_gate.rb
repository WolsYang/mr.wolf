class ShootTheGate < ApplicationRecord
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

  def self.shoot(received_text, channel_id, bet = 0, basic_bet = 10)
    game = ShootTheGate.find_or_create_by(channel_id: channel_id)
    if received_text =~ /^小賭怡情\d*/
      players = received_text[4..5]
      game.update(stakes: basic_bet*players.to_i, gambling: "Yes")
    end

    if received_text =~ /^我賭\d*/ && game.gambling == "Yes"
      bet = basic_bet if received_text[2].nil?
      return "獎金池沒了...請重新輸入關鍵字設定" if game.stakes == 0
      (2...received_text.size).each do |n|
        unless received_text[n].match(%r{[0-9]|\s}).nil?
          bet = received_text[2..n]
        end
      end
      bet = game.stakes if bet.to_i > game.stakes #獎金池&最大注 
      self.shoot("射", channel_id, bet.to_i)
    end
     
    case received_text
      when  "重抽"
        poker = Poker.shuffle(1)
        game.update(cards: poker)
        return  "射龍門開始啦~~~~~~~~~~~~請輸入 \"抽\" 繼續"
      when "抽"
        card1 = game.cards.delete_at(0)
        game.update(card1: card1)
        number1 = ShootTheGate.to_number(card1)
        card2 = game.cards.delete_at(0)
        game.update(card2: card2)
        number2 = ShootTheGate.to_number(card2)
        now_cards = game.cards
        game.update(cards: now_cards)
        return card1+card2
      when "射"
        puts "抽" 
        puts game.cards.size
        puts game.card1
        puts game.card2
        return "沒牌囉請輸\"重抽\""if game.cards.size < 3
        card1 = game.card1
        number1 = ShootTheGate.to_number(card1)
        card2 = game.card2
        number2 = ShootTheGate.to_number(card2)
        card3 = game.cards.delete_at(0)
        user_number = ShootTheGate.to_number(card3)
        now_cards = game.cards
        game.update(cards: now_cards)
        if number2 > number1#門柱排序 case when條件需要照順序
          number2, number1 = number1, number2
        end
        #result = 0 #這局贏錢的結果 沒賭的話預設是0
        puts user_number.to_s + "   user_number"
        case user_number
          when number2+1...number1-1 
            if game.gambling == "Yes"
              result = game.stakes - bet
              game.update(stakes: result)
              puts "賭博"
              card3 +" \n進啦進啦~~贏錢啦!!!" + "\n您贏" + bet.to_s + "\n目前獎金池" + result.to_s
            else
              puts user_number.to_s + "   user_number"
              card3 +" \n進啦進啦~~!!!" + "您贏了" 
            end
          when number1, number2
            if game.gambling == "Yes"
              result = game.stakes + (bet*2)
              game.update(stakes: result)
              puts "賭博撞柱"
              card3 +" \n撞柱柱柱柱柱柱柱柱柱!!!!兩倍啦~"+ "\n您輸" + (bet*2).to_s + "\n目前獎金池" + +result.to_s
            else
              puts user_number.to_s + "   user_number"
              "撞柱柱柱柱柱柱柱柱柱!!!!輸了QQ"
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
                puts "賭博撞柱"
                card3 +" \n界外球 賠錢拉~~~"+ "\n您輸" + bet.to_s + "\n目前獎金池" + +result.to_s
              else
                puts user_number.to_s + "   user_number"
                card3 +" \n界外球 您輸啦" 
              end            
          #  end
        end
      else
        return nil
    end
  end
end
