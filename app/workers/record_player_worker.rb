require 'line/bot'
class RecordPlayerWorker
  include Sidekiq::Worker
 
	def perform(channel_id)
		#redis= Redis.new
		players = REDIS.lrange(channel_id,0,-1)
		REDIS.del(channel_id)
		kill = Killer.find_by(channel_id: channel_id)
		kill.update(players: players, killer: players.shuffle[1], game_begin: false)
		ChatbotController.new.push_to_line(channel_id, Killer.start_n_rule)
  end
end


