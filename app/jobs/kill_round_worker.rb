class KillRoundWorker < ActiveJob::Base
    # Set the Queue as Default
    queue_as :default

    def perform(channel_id = nil, jid = nil)
    return if cancelled?
      p "+++++++++++++++++++++>@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@<++++++++++++++++++"
      replytext = Killer.vote(channel_id)
      #超過20分鐘沒人投票
      ChatbotController.new.push_to_line(channel_id, replytext, "kill")
    end

    def cancelled?
      Sidekiq.redis {|c| c.exists("cancelled-#{@jid}") }
    end

    def self.cancel!(jid)
      @jid = jid
      Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
    end
    #KillRoundWorker.set(wait: 1.minutes).perform_later.provider_job_id
    #KillRoundWorker.cancel!(jid)
  end