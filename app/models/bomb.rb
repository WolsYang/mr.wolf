class Bomb < ApplicationRecord
	def initialize(channel_id)
		super
		now_max = 10000
		now_min = 1
		user_number = 0
		@now_id = channel_id
		@code = rand(1..now_max-1)
		Channel.find_or_create_by(@now_id).update(now_gaming: "Bomb")
		#bomb.update(user_number: 0, now_max: max, now_min: 1, code: @code, channel_id: channel_id)
	end

    def play(user_number)
      bomb = Bomb.find_by(channel_id: @now_id)
      if bomb.now_min < user_number && user_number < bomb.now_max
          if user_number == @code
            bomb.destroy
            Channel.find_by(channel_id: @now_id).update(now_gaming: "No")
            "恭喜你!!爆爆爆了"
          elsif user_number > @code 
            bomb.update(now_max: user_number)
            bomb.now_min.to_s + " ~ " + bomb.now_max.to_s
          elsif user_number < @code
            bomb.update(now_min: user_number)
            bomb.now_min.to_s + " ~ " + bomb.now_max.to_s
          end
      else
          "您猜的數字不在範圍內\n" '輸入範圍內的數字     ' + bomb.now_min.to_s + " ~ " + bomb.now_max.to_s
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

    def channal_id
      @channel_id 
    end

    def code
      @code
    end

end