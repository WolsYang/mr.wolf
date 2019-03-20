class Api::V1::BargainController < Api::V1::BaseController
    def index(set_ime = 3)
        channel_id = params[:channel_id]
        bargain = Bargain.find_by(channel_id: channel_id)
        if bargain.nil?#新開局
            BargainSetTimeJob.set(wait: set_time.minutes).perform_later(channel_id)
        end
            Bargain.start(channel_id)
            render :json => { :message => "#{bargain.min + set_time}:#{bargain.sec}"}, :status => 200 
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
