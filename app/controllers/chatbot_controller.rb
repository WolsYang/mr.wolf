#ver 1.00
require 'net/http'
require 'line/bot'
class ChatbotController < ApplicationController
	protect_from_forgery with: :null_session	#關閉CSRF

	#主程式
	def webhook
	#* Purpose : 判別回傳正確對話給客戶端(Any type)
 	#* Arguments: LINE客戶端送出訊息(JSON)
  	#* Return on success: reply_text, reply_image
 	#* Return on failure(exceptions):
  	#* Dependance :
	#	查天氣 get_weather(received_text)
	#	記錄頻道 Channel.find_or_create_by(channel_id: channel_id)
	#	學說話 learn(channel_id, received_text)
	#	關鍵字回覆 keyword_reply(channel_id, received_text) if reply_text.nil?
	#	推擠 (ECHO) echo2(channel_id, received_text) if  reply_text.nil?
	#	記錄對話 save_to_received(channel_id, received_text), save_to_reply(channel_id, reply_text)
	#	傳送訊息給LINE reply_to_line(reply_text)
		params['events'].each do |event|
			text = received_text(event, channel_id)
				#記錄頻道
				channel = Channel.find_or_create_by(channel_id: channel_id)
				puts "00000000000000"
				reply_text = game_keyword_reply(channel_id, text)
				#reply_text = received_text(event, channel_id)
				puts "2222"
				response = reply_to_line(reply_text)
				puts "333"
				# 回應200
				head :ok
		end
	end

	# 取得對方說的話
	def received_text(event, channel_id)
		if event['type'] == "message"
			message = event['message']
			message['text'] unless message.nil?	
		#回傳按鈕
		elsif event['type'] == "postback"
			puts "in postback"
			chooise = event['postback']['data']
			id = channel_id
			puts id
			channel = Channel.find_by(channel_id: channel_id)
			puts channel_id.to_s
			#if channel.now_gaming == "no"
				channel.update(now_gaming: event['postback']['data'])
				case chooise
					when "porker"
					when "bomb"
						bomb = Bomb.new
						puts bomb.play
						bomb.save
				end
			#else
			#"您還有遊戲進行中"
			#end	
		end
	end

	# 訊息來源ID
	def channel_id
		source = params['events'][0]['source']
		source['groupId'] ||source['roomId'] ||source['userId']
		#原始長這樣
		#return source['groupID'] unless source['groupID'].nil?
		#return source['roomID'] unless source['roomID'].nil?
		#source['userID']
	end

	def game_keyword_reply(channel_id, received_text)
		if received_text[0...6] == '我要玩遊戲'	
			"玩遊戲囉"
		elsif received_text[0...1] == '我猜' 
			bomb = Bomb.find_by(channel_id: channel_id)
			user_number = bomb.guess(received_text)
			puts bomb.code
			puts bomb.play(user_number)
			result = bomb.play(user_number)
		else
			return nil
		end	
	end

	#傳送訊息到LINE
	def reply_to_line(reply_text)
		puts "444"
		return nil if reply_text.nil?
		puts "555"
		# 取得reply token
		reply_token = params['events'][0]['replyToken']
		puts "666"		
		# 設定回覆訊息
		message = {
  			"type": "template",
		 	"altText": "不支援時的文字",
			"template": {
			    "type": "buttons",
			    "text": reply_text,
      			"actions": [
          			{
            		"type": "postback",
           			"label": "終極密碼",
            		"data": "bomb",
            		"dataText": "玩玩玩玩玩玩玩"
          			},
          			{
			        "type": "postback",
			        "label": "porker",
			        "data": "action=add&itemid=123"
			        }
      			]
  			}
		}
	puts "888"
		# 傳送訊息 一個方法的回傳值是最後一行的結果
		line.reply_message(reply_token, message)
	puts "999"
	end			
	# Line bot api 初始化
	def line
		return @line unless @line.nil?
		@line = Line::Bot::Client.new{|config|
			config.channel_secret = '1634ed3b33c15e2cf579018b98920968'
			config.channel_token ='VsnoSZR++5ejxl+LTwHVL8bHnEVi9xDozwQ5ajtK9t+BtGEn/Jt54fDBMFq0dO93rFJp7bwnz4ta0k/3DVqpReRlTFJSoEl+IG8S4CO+ucvA0j/rZ8Lsc/tjWRzLWCdFgR3BKOJNn8HdxOXZpw19mAdB04t89/1O/w1cDnyilFU='
		}
	end


end
