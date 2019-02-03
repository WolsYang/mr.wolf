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
			text = received_text(event)
				#記錄頻道
				Channel.find_or_create_by(channel_id: channel_id(event))

				reply_text = keyword_reply(channel_id, text)
				puts "2222"
				response = reply_to_line(reply_text)
				puts "333"
				# 回應200
				head :ok
		end
	end

	# 取得對方說的話
	def received_text(event)
		if event['type'] == "message"
			message = event['message']
			message['text'] unless message.nil?	
		elsif event['type'] == "postback"
			chooise = event['postback']['data']
			puts chooise
		end
	end

	# 頻道ID
	def channel_id(event)
		source = event['source']
		source['groupId'] ||source['roomId'] ||source['userId']
		#原始長這樣
		#return source['groupID'] unless source['groupID'].nil?
		#return source['roomID'] unless source['roomID'].nil?
		#source['userID']
	end

	def keyword_reply(channel_id, received_text)
		return "什麼東西" unless received_text[0...6] == '我要玩遊戲'	
		"玩遊戲囉"	
	end

	#傳送訊息到LINE
	def reply_to_line(reply_text)
		puts "444"
		return nil if reply_text.nil?
		puts "555"
		# 取得reply token
		reply_token = event['replyToken']
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
            		"data": "action=buy&itemid=123",
            		"text": "玩玩玩玩玩玩玩"
          			},
          			{
			        "type": "postback",
			        "label": "射龍門",
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
