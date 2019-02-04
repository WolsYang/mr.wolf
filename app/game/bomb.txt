class Bomb
  def initialize(channel_id)
    @now_max = 10000
    @now_min = 1
      @code = rand(1..@now_max-1)
      @user_number = 0
      @channel_id = channel_id
    end

  def c
      @channel_id 
    end

    def play(user_number = @user_number, now_max = @now_max, now_min = @now_min)
      bomb = Bomb.find_by(channel_id: @channel_id)
      channel = Channel.find_by(channel_id: channel_id)
      if now_min < user_number && user_number < now_max
          if user_number == @code
            bomb.destroy
            channel.update(now_gaming: "no")
            puts "恭喜你!!爆爆爆了"
          elsif user_number > @code 
            channel.update (now_max: user_number)
            puts "#{now_min.to_s}~#{now_max.to_s}"
          elsif user_number < @code
            channel.update (now_min: user_number)
            puts "#{now_min.to_s}~#{now_max.to_s}"
          end
      else
          puts "您猜的數字不在範圍內 "
          puts "請輸入範圍內的數字   " + now_min.to_s + " ~ " + now_max.to_s
      end 
    end

    #判斷用戶回傳的字串
    def guess(text)
      unless text[2].match(%r{[0-9]}) ==nil 
          number = text[2]
          unless text[3].match(%r{[0-9]}) ==nil 
            number += text[3] 
          end
          unless text[4].match(%r{[0-9]}) ==nil 
            number += text[4] 
          end
          unless text[5].match(%r{[0-9]}) ==nil 
            number += text[5] 
          end
          if text[6].match(%r{[0-9]}) ==nil 
            number.to_i
          else 
            number += text[6]
          end
      else
        #回傳不在範圍內的值
          number = 999999
      end
    end 
end