class BargainSetTimeJob < ApplicationJob
  queue_as :default

  def perform(channel_id)
    text = Bargain.time_up(channel_id)
    ChatbotController.new.push_to_line(channel_id, text)
    Bargain.game_end(channel_id)
  end
end
#.set(wait: 20.minutes).perform_later(channel_id, player)