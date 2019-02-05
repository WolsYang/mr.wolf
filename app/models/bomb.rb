class Bomb < ApplicationRecord
	def start(channel_id)
		now_max = 10000
		now_min = 1
		user_number = 0
		code = rand(1..now_max-1)
		Channel.find_or_create_by(channel_id: channel_id).update(now_gaming: "Bomb")
		Bomb.find_or_create_by(channel_id: channel_id).update(user_number: user_number, now_max: now_max, now_min: now_min, code: code)
	end

    def self.play(user_number, channel_id)
        bomb = Bomb.find_by(channel_id: channel_id)
        if bomb.now_min < user_number && user_number < bomb.now_max
            if user_number == bomb.code
                bomb.destroy
                Channel.find_by(channel_id: channel_id).update(now_gaming: "No")
                "恭喜你!!爆爆爆了"
            elsif user_number > bomb.code 
            	bomb.update(now_max: user_number)
            	bomb.now_min.to_s + " ~ " + bomb.now_max.to_s
            elsif user_number < bomb.code
            	bomb.update(now_min: user_number)
            	bomb.now_min.to_s + " ~ " + bomb.now_max.to_s
          	end
      	else
          	"您猜的數字不在範圍內\n" '輸入範圍內的數字     ' + bomb.now_min.to_s + " ~ " + bomb.now_max.to_s
      	end 
    end

    #判斷用戶回傳的字串
    def self.guess(text)
      	size = text.size > 5 ? 5 : text.size
      	number = 99999
      	#超過5個字元一定會超出範圍
        (2...size).each do |n|
          	unless text[n].match(%r{[0-9]}).nil? 
            	number = text[2..n]
          	else
            	break
          	end
        end
  	  	number.to_i
  	end 
end