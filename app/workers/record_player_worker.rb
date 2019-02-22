class RecordPlayerWorker
  include Sidekiq::Worker
 
	def perform(channel_id)
		p "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		Killer.start_n_rule(channel_id)
  end
end



