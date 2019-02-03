class Bomb

  def self.code(number)
    code =rand(1..number)
  end

  def self.play(now_max, now_min = 1, user_number)
    if now_min < user_number && user_number < now_max
      if user_number == c 
        puts "爆了"

      elsif user_number > c 
          now_max = user_number
          puts "#{now_min.to_s}~#{now_max.to_s}"
      
      elsif user_number < c
          now_min = user_number
          puts "#{now_min.to_s}~#{now_max.to_s}"
      end
    else
      puts user_number
      puts "請輸入範圍內的數字" + now_min.to_s + "~" + now_max.to_s
    end 
  end 
end