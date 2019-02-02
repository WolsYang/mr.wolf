require 'line/bot'
class PushMessagesController < ApplicationController
	before_action :authenticate_user!
	
	#GET /push_messages/new
	def new
	end
	
	#POST /push_messages 接收到請求後發訊息
	def create
		text = params[:text]
		Channel.all.each do |channel|
			push_to_line(channel.channel_id, text)
		end
		redirect_to '/push_messages/new'
	end
	
	#傳訊息到LINE
	def push_to_line(channel_id, text)
		return nil if channel_id.nil? or text.nil?
		
		#設定回復訊息
		message = {
			type: 'text',
			text: text
		}
		
		#傳送訊息
		line.push_message(channel_id, message)
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