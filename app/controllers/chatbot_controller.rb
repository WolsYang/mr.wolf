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
				Channel.find_or_create_by(channel_id: channel_id)
				# 回應200
				head :ok
		end
	end

	# 頻道ID
	def channel_id
		source = params['events'][0]['source']
		source['groupId'] ||source['roomId'] ||source['userId']
		#原始長這樣
		#return source['groupID'] unless source['groupID'].nil?
		#return source['roomID'] unless source['roomID'].nil?
		#source['userID']
	end

	def game(channel_id, received_text)
		return nil unless received_text[0...6] == '我要玩遊戲'
		
		# 取得reply token
		reply_token = params['events'][0]['replyToken']
				
		# 設定回覆訊息
		message = {
  			"type": "template",
		 	"altText": "This is a buttons template",
			"template": {
			    "type": "buttons",
			    "title": "Menu",
			    "text": "請選擇您要玩的遊戲",
      			"actions": [
          			{
            		"type": "postback",
           			"label": "終極密碼",
            		"data": "action=buy&itemid=123",
            		"displayText" : "displayText"
          			},
          			{
			        "type": "postback",
			        "label": "射龍門",
			        "data": "action=add&itemid=123"
			        },
			        {
			        "type": "吹牛",
			        "label": "View detail",
			        "uri": "http://example.com/page/123"
			        },
			        {
			        "type": "殺手",
			        "label": "View detail",
			        "uri": "http://example.com/page/123"
			        }
      			]
  			}
		}
		# 傳送訊息 一個方法的回傳值是最後一行的結果
		line.reply_message(reply_token, message)
	end

	#傳送訊息到LINE
	def reply_to_line(reply_text)
		return nil if reply_text.nil?
		
		# 取得reply token
		reply_token = params['events'][0]['replyToken']
				
		# 設定回覆訊息
		message = {
			type: 'text',
			text: reply_text
		}
		
		# 傳送訊息 一個方法的回傳值是最後一行的結果
		line.reply_message(reply_token, message)
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
