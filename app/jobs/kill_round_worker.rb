class KillRoundWorker < ActiveJob::Base
    # Set the Queue as Default
    queue_as :default

    def perform(channel_id = nil, player = nil)
      p "+++++++++++++++++++++>@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@<++++++++++++++++++"
      p cancelled?
    return if cancelled?
      p "+++++++++++++++++++++>@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@<++++++++++++++++++"
      #kill = Killer.find_or_create_by(channel_id: channel_id)
      #REDIS.set(channel_id, kill.players.size.to_s) 
      #Killer.rounds(player, channel_id)
      replytext = Killer.vote(channel_id)
      p replytext
      p "KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK"
      #超過20分鐘沒人投票
      ChatbotController.new.push_to_line(channel_id, replytext, "kill")
    end

    def cancelled?
      p @jid
      p "ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
      Sidekiq.redis {|c| c.exists("cancelled-#{@jid}") }
    end

    def self.cancel!(jid)
      @jid = jid
      Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
    end
    #KillRoundWorker.set(wait: 1.minutes).perform_later.provider_job_id
    #KillRoundWorker.cancel!(jid)
  end