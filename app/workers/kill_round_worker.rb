class KillRoundWorker
    include Sidekiq::Worker
   
      def perform
          return if cancelled?
          p "+++++++++++++++++++++++++++++++++++++++"
      end
  
      def cancelled? (jid)
      Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
      end
  end