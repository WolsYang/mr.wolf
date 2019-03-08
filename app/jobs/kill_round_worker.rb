#redis方法不能用 變相寫一個
class KillRoundWorker < ActiveJob::Base
    # Set the Queue as Default
    queue_as :default

    def perform(channel_id = nil, player = nil)
      return if REDIS.get("jid"+channel_id).nil?
      Killer.vote(channel_id)
    end

    #KillRoundWorker.set(wait: 1.minutes).perform_later.provider_job_id
    #KillRoundWorker.cancel!(jid)
  end