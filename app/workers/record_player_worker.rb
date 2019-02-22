class RecordPlayerWorker
  include Sidekiq::Worker
 
	def perform(channel_id)
		Killer.start_n_rule(channel_id)
  end
end



