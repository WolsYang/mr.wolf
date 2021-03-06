class Api::V1::BargainController < Api::V1::BaseController
    def index(set_time = 3)#單位 分鐘
        channel_id = params[:channel_id]
        bargain = Bargain.find_by(channel_id: channel_id)
        if bargain.nil?#新開局
            Bargain.start(channel_id)
            bargain = Bargain.find_by(channel_id: channel_id)
            BargainSetTimeJob.set(wait: set_time.minutes).perform_later(channel_id)
        end
        reciprocal = bargain.created_at.to_i + set_time*60 - Time.now.to_i 
        render :json => { :time => reciprocal}, :status => 200 
    end
  
    def new_bid
         render :json => { :message =>Bargain.check(params[:channel_id], params[:user_bid].to_i, params[:user_name])}, :status => 200 
    end

    def now_win
        render :json => { :message => Bargain.time_up(channel_id: params[:channel_id])}, :status => 400 
    end
  
    def game_end
        render :json => { :message => Bargain.game_end(channel_id)}, :status => 200
    end

end
