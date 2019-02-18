require 'line/bot'
class RecordPlayerWorker
  include Sidekiq::Worker
 
  def perform(channel)
		p channel.now_gaming
  end
end
