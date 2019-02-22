class RecordPlayerWorker
  include Sidekiq::Worker
 
	def perform(channel_id)
		return if REDIS.lrange(channel_id,0,-1).nil?
		p "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		Killer.start_n_rule(channel_id)
  end
end



