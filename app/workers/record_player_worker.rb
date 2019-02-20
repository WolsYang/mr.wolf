require 'line/bot'
class RecordPlayerWorker
  include Sidekiq::Worker
 
	def perform(channel_id)
		#redis= Redis.new
		players = REDIS.lrange(channel_id,0,-1)
		kill = Killer.find_by(channel_id: channel_id)
		kill.update(players: players, killer: players.shuffle[1], game_begin: false)
		text = "遊戲開始啦 ~ 
					\n1.接下來將會從玩家中隨機挑出一名殺手
					\n2.殺手在天黑時選取欲殺害的玩家
					\n3.天亮時其餘玩家可投票誰是殺手，得票最高的玩家會被處決
					\n4.如果最後僅剩一位玩，殺手就贏得這個遊戲囉～"
  end
end
