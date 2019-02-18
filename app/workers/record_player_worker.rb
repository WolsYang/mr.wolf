require 'line/bot'
class RecordPlayerWorker
  include Sidekiq::Worker
 
  def perform(channel)
		p channel
  end
end
