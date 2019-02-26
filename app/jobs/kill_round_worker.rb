#redis方法不能用 變相寫一個
class KillRoundWorker < ActiveJob::Base
    # Set the Queue as Default
    queue_as :default

    def perform(channel_id = nil, player = nil)
      p "+++++++++++++++++++++>@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@<++++++++++++++++++"
      return if REDIS.get("jid"+channel_id).nil?
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

    #KillRoundWorker.set(wait: 1.minutes).perform_later.provider_job_id
    #KillRoundWorker.cancel!(jid)
  end