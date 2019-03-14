class Api::V1::BargainController < Api::V1::BaseController
    def index
        #Bargain.start("for_api_test")
        #render :json => { :message => Bargain.rule }, :status => 200 
    end
  
    def new_bid
         render :json => { :message =>Bargain.check("for_api_test", params[:user_bid].to_i)}, :status => 200 
    end

    def now_win_bid
        render :json => { :message => "Bargain.now_win_bid(channel_id)"}, :status => 400 
    end
  
    def game_end
        render :json => { :message => "Bargain.game_end(channel_id)"}, :status => 400 
    end

    def show
        @bargain = Bargain.find(params[:id])
    end
end
