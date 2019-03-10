class Bomb < ApplicationRecord
	def self.rule
		"開始拉~~範圍是 1 ~ 10000
		\n請輸入心中所想的整數
		\n例如:4841
		\n1.若是猜到密碼炸彈就引爆啦
		\n2.若是沒有猜道則縮小範圍 例如: 1 ~ 4841 或 4841 ~ 1000
		\n來看看誰這麼Lucky阿~"
	end

	def self.start(channel_id)
		now_max = 10000
		now_min = 1
		user_number = 0
		code = rand(1..now_max-1)
		Bomb.find_or_create_by(channel_id: channel_id).update(user_number: user_number, now_max: now_max, now_min: now_min, code: code)
	end

	def self.play(user_number, channel_id)
        bomb = Bomb.find_by(channel_id: channel_id)
        if bomb.now_min < user_number && user_number < bomb.now_max
            if user_number == bomb.code
                bomb.destroy
                Channel.find_by(channel_id: channel_id).update(now_gaming: "no")
                "恭喜你!!爆爆爆了\n不如請我喝一杯飲料吧:)"
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
      	size = text.size > 4 ? 4 : text.size
      	number = 99999
      	#超過5個字元一定會超出範圍
        (0...size).each do |n|
          	unless text[n].match(%r{[0-9]|\s}).nil? 
            	number = text[0..n]
          	else
            	break
          	end
        end
  	  	number.to_i
  	end 
end