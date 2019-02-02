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
				#查天氣
				"""
				#reply_image = get_weather(text)
				#觸發到到後面的事件就不跑了
				unless reply_image.nil?
				#	#傳送訊息到LINE
					response = reply_image_to_line(reply_image)
					#回應200
					head :ok
					return
				end
				"""
				#記錄頻道
				Channel.find_or_create_by(channel_id: channel_id)

				"""
				#學說話
				reply_text = learn(channel_id, text)

				# 關鍵字回覆
				reply_text= keyword_reply(channel_id, text) if reply_text.nil?

				# 推擠 (ECHO)
				reply_text = echo2(channel_id, text) if  reply_text.nil?

				# 記錄對話
				save_to_received(channel_id, text)
				save_to_reply(channel_id, reply_text)
				

				# 傳送訊息給LINE
				response = reply_to_line(reply_text)
				"""


				# 回應200
				head :ok
		end
	end
	"""
	#查天氣方法
	def get_weather(received_text)
		return nil unless received_text.include? '天氣'
		upload_to_imgur(get_weather_from_cwb)
	end

	#取得最新雷達回波圖
	def get_weather_from_cwb
		uri = URI('https://www.cwb.gov.tw/V7/js/HDRadar_1000_n_val.js')
		response = Net::HTTP.get(uri)
		start_index = response.index('","') + 3
		end_index = response.index('"),') - 1
		"https://www.cwb.gov.tw" + response[start_index..end_index]
	end

	#上傳圖片到imgur
	def upload_to_imgur(image_url)
		#準備發送 Post request
		url = URI("https://api.imgur.com/3/image")
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		request = Net::HTTP::Post.new(url)
		#要送出的Request header
		request["authorization"] = 'Client-ID 2a926b97a45f217'

		#設定request_body 送出request
		request.set_form_data({"image" => image_url})
		response = http.request(request)

		#imgur 回傳JASON 解析 若失敗回傳 nil 避免崩潰
		# 假設收到的是一個json字串把他轉為Hash(雜湊陣列)
		json = JSON.parse(response.read_body)
		begin
			#從hash中取出網址並把 http改成https
			json['data']['link'].gsub("http:","https:")
			#當第一段程式碼出問題就攔截這個錯誤 回傳 nil(不做了)
		rescue
			nil
		end
	end

	#傳送圖片到Lline
	def reply_image_to_line(reply_image)
		return nil if reply_image.nil?

		#取得reply token
		reply_token = params['events'][0]['replyToken']

		#設定回覆訊息
		message = {
			type: "image",
			originalContentUrl: reply_image,
			previewImageUrl: reply_image
		}

		#t傳送訊息
		line.reply_message(reply_token, message)
	end
	'''
	# 頻道ID
	def channel_id
		source = params['events'][0]['source']
		source['groupId'] ||source['roomId'] ||source['userId']
		#原始長這樣
		#return source['groupID'] unless source['groupID'].nil?
		#return source['roomID'] unless source['roomID'].nil?
		#source['userID']
	end
	'''
	# 儲存對話
	def save_to_received(channel_id, received_text)
		return if received_text.nil?
		Received.create(channel_id: channel_id, text: received_text)
	end

	#儲存回應
	def save_to_reply(channel_id, reply_text)
		return if reply_text.nil?
		Reply.create(channel_id: channel_id, text: reply_text)
	end

	#echo人云亦云
	def echo2(channel_id, received_text)
		#如果在chanel_id最近沒人講過received_text,就不回應
		recent_received_texts = Received.where(channel_id: channel_id).last(5)&.pluck(:text)
		return nil unless received_text.in? recent_received_texts
	
		#如果在chanel_id上一個講過received_text是自己就不回
		last_reply_text = Reply.where(channel_id: channel_id).last&.text
		return nil if last_reply_text == received_text
		
		received_text
	end

	# 取得對方說的話
	def received_text(event)
		message = event['message']
		message['text'] unless message.nil?	
		#if message.nil?
		#	nil
		#else
		#	message['text']
		#end
	end

	#學說話 同時記錄不同CHANEL的教學內容
	def learn(channel_id, received_text)
		#如果開頭不是學說話關鍵字; 就跳出
		return nil unless received_text[0..6] == '苦命狼幫我記;'
		
		#取剩下來的字 以 " ; "  為切割點
		received_text = received_text[7..-1]
		semicolon_index = received_text.index(';')
		
		#找不到分號就跳出
		return nil if semicolon_index.nil?
		
		keyword = received_text[0..semicolon_index-1]
		message = received_text[semicolon_index+1..-1]
		
		KeywordMapping.create(channel_id: channel_id, keyword: keyword,message: message)
		'是!!小得遵命'
	end

	#關鍵字回覆
	def keyword_reply(channel_id, received_text)
		message = KeywordMapping.where(channel_id: channel_id, keyword: received_text).last&.message
		return message unless message.nil?
		
		#&.前如果是nil 就不會執行後面的東西
		KeywordMapping.where(keyword: received_text).last&.message
		#沒縮減前
		#mapping = KeywordMapping.where(keyword: received_text).last
		#if mapping.nil
		#	nil
		#else
		#	mapping.message
		#end
	end
	'''
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
            		"data": "action=buy&itemid=123"
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
			        "text": "http://example.com/page/123"
			        }
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
