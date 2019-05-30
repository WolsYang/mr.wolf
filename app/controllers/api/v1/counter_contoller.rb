class Api::V1::CounterController < Api::V1::BaseController
    def index(set_star = 0)
        channel_id = params[:channel_id]
        counter = Counter.find_by(channel_id: channel_id)
        if Counter.nil?#新開局
            counter = Counter.create(:channel_id => channel_id, :now_wating => set_star)
        end
        render :json => { :message=> "現在等待人數" + counter.now_wating}, :status => 200 
    end
  
    def incr
        render :json => { :message=> "現在等待人數" + counter.now_wating}, :status => 200  
    end

    def deincr
        render :json => { :message=> "現在等待人數" + counter.now_wating}, :status => 200  
    end

end
