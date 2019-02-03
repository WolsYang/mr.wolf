class Channel < ApplicationRecord
	def self.no_game_now(channel_id)
		channel = Channel.find_by(channel_id: channel_id)
		result = ( false if channel.bomb = true) 
	end
end
