require 'line/bot'
class RecordPlayerWorker
  include Sidekiq::Worker
 
	def perform(channel)
		p "........................................."
		p channel
  end
end
