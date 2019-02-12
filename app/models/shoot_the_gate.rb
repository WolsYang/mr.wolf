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

  def self.shoot(recevided_text, channel_id, bet = 0)
    cards = ShootTheGate.find_or_create_by(channel_id: channel_id)
    if recevided_text =~ /^小賭怡情\d*/
      basic_bet = 10#底注
      players = recevided_text[4..5]
      cards.update(stakes: basic_bet*players, gambling: "Yes")
    end

    if recevided_text =~ /^我賭\d*/ && cards.gambling == "Yes"
      unless casds.stakes == 0
        (2...recevided_text.size).each do |n|
          unless recevided_text[n].match(%r{[0-9]|\s}).nil?
            if bet.to_i  > casds.stakes
              bet =casds.stakes#獎金池&最大注
              break 
            end
            bet = recevided_text[2..n]
            bet.to_i
          end
        end
      else
        return "獎金池沒了...請重新輸入關鍵字設定"
      end
      self.shoot( "射", bet, channel_id)
    end
     
    case recevided_text
      when  "重抽"
        porker = Poker.shuffle(1)
        cards.update(cards: porker)
        return  "射龍門開始啦~~~~~~~~~~~~請輸入 \"抽\" 繼續"
      when "抽"
        card1 = ShootTheGate.find_by(channel_id: channel_id).cards.delete_at(0)
        cards.update(card1: card1)
        number1 = ShootTheGate.to_number(card1)
        card2 = ShootTheGate.find_by(channel_id: channel_id).cards.delete_at(0)
        cards.update(card1: card2)
        number2 = ShootTheGate.to_number(card2)
      when "射"
        #找或建 依channel_id
        #puts "抽" 
        #puts @now_min + "@now_min"
        #puts @now_max + "@now_max"
        #puts @now_min[2] + "@now_min[2]"
        #puts @now_max[2] + "@now_max[2]"
        if ShootTheGate.find_by(channel_id: channel_id).cards.size < 3
          porker = Poker.shuffle(1)
          cards.update(cards: porker)
          self.shoot( "射", bet, channel_id)
        end
          ShootTheGate.shoot(received_text: received_text, channel_id: channel_id)
        card3 = ShootTheGate.find_by(channel_id: channel_id).cards.delete_at(0)
        user_number = ShootTheGate.to_number(card3)
        if number2 > number1#門柱排序 case when條件需要照順序
          number2, number1 = number1, number2
        end
        #result = 0 #這局贏錢的結果 沒賭的話預設是0
        puts user_number.to_s + "   user_number"
        case user_number
          when number2+1...number1-1 
            if cards.gambling == "Yes"
              result = cards.stakes - bet
              cards.update(stakes: result)
              puts "賭博"
              "進啦進啦~~贏錢啦!!!" + "您贏" + bet.to_s + "目前獎金池" + result.to_s
            else
              puts user_number.to_s + "   user_number"
              "進啦進啦~~!!!" + "您贏了" 
            end
          when number1, number2
            if cards.gambling == "Yes"
              result = cards.stakes + (bet*2)
              cards.update(stakes: result)
              puts "賭博撞柱"
              "撞柱柱柱柱柱柱柱柱柱!!!!兩倍啦~"+ "您輸" + (bet*2).to_s + "目前獎金池" + +result.to_s
            else
              puts user_number.to_s + "   user_number"
              "撞柱柱柱柱柱柱柱柱柱!!!!輸了QQ"
            end           
          else
            if cards.gambling == "Yes"
              result = cards.stakes + bet
              cards.update(stakes: result)
              puts "賭博撞柱"
              "界外球 賠錢拉~~~"+ "您輸" + bet.to_s + "目前獎金池" + +result.to_s
            else
              puts user_number.to_s + "   user_number"
              "界外球 您輸啦" 
            end            
        end
      else
        return nil
    end
  end
end
