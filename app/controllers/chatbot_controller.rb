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
		if event['message']['text'] == "+1"
			profiile = line.get_profile(params['events'][0]['source']['userId'])
			#case response
			#when Net::HTTPSuccess then
			contact = JSON.parse(response.body)
			p contact['displayName']
			p contact['pictureUrl']
			p contact['statusMessage']
			else
			  p "#{response.code} #{response.body}"
			end
		else
			channel = Channel.find_or_create_by(channel_id: channel_id)
			params['events'].each do |event|
			text = received_text(event)
				#記錄頻道				
				reply_text = game_keyword_reply(channel_id, text)
				response = #reply_to_line(reply_text)
				# 回應200
				head :ok
		end
	end

	# 取得對方說的話
	def received_text(event)
		if event['type'] == "message"
			p " message"
			#統計+1數
			case event['message']['text']
				when "+1"
					p "在+1這"
					p webhook
				else
					p "普通"
					message = event['message']
					message['text'] unless message.nil?	
			end
		#按鈕回傳的訊息
		elsif event['type'] == "postback"
			puts event['postback']['data']
			chooise = event['postback']['data']
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
		puts received_text
		channel = Channel.find_by(channel_id: channel_id)
		if received_text[0...6] == '我要玩遊戲'	&& channel.now_gaming == "No"
			"玩遊戲囉"
		#elsif received_text[0...6] == '我要玩遊戲'
			#	"您還有遊戲進行中"
		elsif channel.now_gaming == "Bomb" && received_text.match(%r{\D}).nil? == true
			user_number = Bomb.guess(received_text)
			Bomb.play(user_number, channel_id)
		elsif channel.now_gaming == "Shoot" 
			ShootTheGate.shoot(received_text: received_text, channel_id: channel_id)
		elsif received_text[0...4] == 'WY遊戲'
			case received_text[4...8]
				when "bomb"
					channel.update(now_gaming: received_text[4...8])
					puts '在bomb裡'
					Bomb.start(channel_id)
					"開始拉~~範圍是 1 ~ 10000\n請輸入心中所想的整數\n例如:4841\n若是猜到密碼炸彈就引爆啦\n來看看誰這麼Lucky阿~"
				when "shoo"
					channel.update(now_gaming: received_text[4...8])
					Channel.find_or_create_by(channel_id: channel_id).update(now_gaming: "Shoot")
					ShootTheGate.shoot(received_text: received_text, channel_id: channel_id)
					"開始拉~~輸入\"抽\"抽取門柱\n輸入\"射\"抽取射門牌\n若射門牌數字介於門柱牌數字中間就贏啦~\n輸入\"重抽\"換一副牌重新開始"			
			end
		else 			
			return nil
		end	
	end

	#傳送訊息到LINE
	def reply_to_line(reply_text)
		return nil if reply_text.nil?
		# 取得reply token
		reply_token = params['events'][0]['replyToken']	
		# 設定回覆訊息類型
		if reply_text == '玩遊戲囉'			
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
            			"data": "WY遊戲bomb3345678",
            			"dataText": "玩玩玩玩玩玩玩"
          				},
          				{
            			"type": "postback",
           				"label": "射龍門",
            			"data": "WY遊戲shoo3345678",
            			"dataText": "玩玩玩玩玩玩玩"
          				}
      				]
  				}
			}
		else
			message = {
				type: 'text',
				text: reply_text
			}
		end	
		# 傳送訊息 一個方法的回傳值是最後一行的結果
		line.reply_message(reply_token, message)
	end
	
	#取得用戶名稱

	# Line bot api 初始化
	def line
		return @line unless @line.nil?
		@line = Line::Bot::Client.new{|config|
			config.channel_secret = '1634ed3b33c15e2cf579018b98920968'
			config.channel_token ='VsnoSZR++5ejxl+LTwHVL8bHnEVi9xDozwQ5ajtK9t+BtGEn/Jt54fDBMFq0dO93rFJp7bwnz4ta0k/3DVqpReRlTFJSoEl+IG8S4CO+ucvA0j/rZ8Lsc/tjWRzLWCdFgR3BKOJNn8HdxOXZpw19mAdB04t89/1O/w1cDnyilFU='
		}
	end
end
