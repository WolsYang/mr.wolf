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
	#	記錄頻道 Channel.find_or_create_by(channel_id: channel_id)
	#	關鍵字回覆 game_keyword_reply(channel_id, received_text)
	#	取得用戶名稱 get_user_name(userID)
	#	傳送訊息給LINE reply_to_line(reply_text)
		params['events'].each do |event|
		text = received_text(event)
			#記錄頻道				
			reply_text = game_keyword_reply(channel_id, text)
			#if text == "+1"#統計+1數
				#response = get_user_name(params['events'][0]['source']['userId'])
			#else
			response = reply_to_line(reply_text, channel_id) 
			#end
			# 回應200
			head :ok
		end			
	end

	# 取得對方說的話
	def received_text(event)
		if event['type'] == "message"
					message = event['message']
					message['text'] unless message.nil?	
			#按鈕回傳的訊息
		elsif event['type'] == "postback"
			chooise = event['postback']['data']
		end
	end

	def count_player(channel_id)
			RecordPlayerWorker.perform_at(1.minutes.from_now,  )
	end

	def game_keyword_reply(channel_id, received_text)
		channel = Channel.find_or_create_by(channel_id: channel_id)
		if received_text[0...5] == '我要玩遊戲'	&& channel.now_gaming == "no"
			"玩遊戲囉"
		elsif received_text[0...5] == '我要玩遊戲' 
			"您還有遊戲進行，若您想玩其他遊戲或結束目前遊戲
			\n請輸入 \"結束所有遊戲\""
		elsif received_text[0...7] == "結束所有遊戲"
			case channel.now_gaming
				when "bomb"
					Bomb.find_or_create_by(channel_id: channel_id).destroy
				when "shoot"
					ShootTheGate.find_or_create_by(channel_id: channel_id).destroy
			end
			channel.update(now_gaming: "no")
			">\"<掰掰~"
		elsif channel.now_gaming == "bomb" && received_text.match(%r{\D}).nil? == true
			user_number = Bomb.guess(received_text)
			Bomb.play(user_number, channel_id)
		elsif channel.now_gaming == "shoot" 
			ShootTheGate.shoot(received_text, channel_id)
		elsif  channel.now_gaming == "kill"
				kill = Killer.find_or_create_by(channel_id: channel_id)
				user_id = params['events'][0]['source']['userId']
				user_name = get_user_name(user_id)
				player = Killer.to_gameid(user_id, user_name)
				p kill.game_begin.to_s
			if kill.game_begin & received_text == "+1"
				p "+1+1+1+1+1+1+1+1+1+1+1+1"
				#判斷player是否已存在
				REDIS.rpush(channel_id, player)
			elsif params['events'][0]['type'] == "postback"
					has_vote = params['events'][0]['postback']['data']
					Killer.round(player, channel_id, has_vote)
			end
		elsif received_text[0...4] == 'WY遊戲'
			case received_text[4...8]
				when "bomb"
					channel.update(now_gaming: received_text[4...8])
					Bomb.start(channel_id)
					Bomb.rule
				when "shoo"
					channel.update(now_gaming: received_text[4...9])
					poker = Poker.shuffle(1)
					gate = ShootTheGate.find_or_create_by(channel_id: channel_id)
					gate.update(cards: poker)
					ShootTheGate.rule
				when "kill"		
					channel.update(now_gaming: received_text[4...8])
					kill = Killer.find_by(channel_id: channel_id)
					kill.update(game_begin: true)
					RecordPlayerWorker.perform_at(1.minutes.from_now, channel_id)
					Killer.rule
			end
		else 			
			return nil
		end	
	end

	#傳送訊息到LINE
	def reply_to_line(reply_text, channel_id)
		return nil if reply_text.nil?
		# 取得reply token
		reply_token = params['events'][0]['replyToken']	
		# 設定回覆訊息類型
		if reply_text == '玩遊戲囉'			
			message2 = {
				type: 'text',
				text: "EEEEEEEEEEEEEEEEEEEEEEEEEE"
			}
			message = {
				"type": "template",
			    "altText": "小遊戲選單",
			    "template": {
				  	"type": "buttons",
				 	 "text": "小遊戲選單",
					"actions": [
						{
					    "type": "postback",
						"label": "終極密碼",
					  	"data": "WY遊戲bomb3345678"
						},
						{
					  	"type": "postback",
						"label": "射龍門",
					  	"data": "WY遊戲shoot3345678"
						},
						{
					  	"type": "postback",
						"label": "天黑請閉眼",
					  	"data": "WY遊戲kill3345678"
						}
					]
				}
			},message2 
		#elsif channel.now_gaming == "kill" 
		else
			message = {
				type: 'text',
				text: reply_text
			}
		end	
		# 傳送訊息 一個方法的回傳值是最後一行的結果
		line.reply_message(reply_token, message)
	end
	
	#主動發訊息
	def push_to_line(userID, text)
		message = {
			type: 'text',
			text: text
		  }
		line.push_message(userID, message)
	end

	#取得用戶名稱
	def get_user_name(userID)
		#return nil unless params['events'][0]['message']['text'] == "+1"
		response = line.get_profile(userID)
		#取得客戶資料後回傳
		#case response
		#when Net::HTTPSuccess then
		contact = JSON.parse(response.body)
		#  p contact['displayName']
		#  p contact['pictureUrl']
		#  p contact['statusMessage']
		#end
		return contact['displayName']
	end

	# Line bot api 初始化
	def line
		return @line unless @line.nil?
		@line = Line::Bot::Client.new{|config|
			config.channel_secret = '1634ed3b33c15e2cf579018b98920968'
			config.channel_token ='VsnoSZR++5ejxl+LTwHVL8bHnEVi9xDozwQ5ajtK9t+BtGEn/Jt54fDBMFq0dO93rFJp7bwnz4ta0k/3DVqpReRlTFJSoEl+IG8S4CO+ucvA0j/rZ8Lsc/tjWRzLWCdFgR3BKOJNn8HdxOXZpw19mAdB04t89/1O/w1cDnyilFU='
		}
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

end
