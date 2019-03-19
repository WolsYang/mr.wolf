class Api::V1::BargainController < Api::V1::BaseController
    def index
        Bargain.start(params[:channel_id])
    end
  
    def new_bid
         render :json => { :message =>Bargain.check(params[:channel_id], params[:user_bid].to_i),"user_name"}, :status => 200 
    end

    def now_win_bid
        render :json => { :message => "Bargain.find_by(channel_id: channel_id).now_win_bid"}, :status => 400 
    end
  
    def game_end
        render :json => { :message => "Bargain.game_end(channel_id)"}, :status => 400 
    end

    def show
        @bargain = Bargain.find(params[:id])
    end
end
