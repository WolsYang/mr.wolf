class BargainController < ApplicationController
    layout "liff"

    def index
        "Bargain.start(channel_id)"
        "render :json => { :message => "Bargain.rule" }, :status => 400" 
    end
  
    def new_bid
        render :json => { :message =>"Bargain.check(channel_id, message)"}, :status => 400 
    end

    def now_win_bid
        render :json => { :message => "Bargain.now_win_bid(channel_id)"}, :status => 400 
    end
  
    def game_end
        render :json => { :message => "Bargain.game_end(channel_id)"}, :status => 400 
    end
end
