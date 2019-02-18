class RecordPlayerWorker
  include Sidekiq::Worker

  def perform()
    p 'SUCEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEESSSSSSSSSS'
    
    #message = {
		#	type: 'text',
		#	text: "成功拉成功拉"
		#  }
		#line.push_message("Uf6d33a17cf0bce9a91e285c7beabc220", message)
  end
end
