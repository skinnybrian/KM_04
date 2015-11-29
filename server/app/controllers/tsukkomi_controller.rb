class TsukkomiController < ApplicationController
  def tsukkomi_all
    datas = Plain.all.select(:id).order(id: :asc)
    base_url = "http://localhost:3000/voice"
    result_data = Array.new
    datas.each do |data|
      result_data.push(data.id.to_s + ".wav")
    end
    render json: {data: result_data, base_url: base_url, count: result_data.length}
  end

  def analysis
    
  end
end
