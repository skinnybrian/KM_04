class TsukkomiController < ApplicationController
  def tsukkomi_all
    datas = Plain.all.select(:id).order(id: :asc)
    base_url = "http://localhost:3000/voice"
    result_data = Array.new
    datas.each do |data|
      result_data.push(data.id.to_s + ".wav")
    end
    render json: {voice: result_data, base_url: base_url, count: result_data.length}
  end

  def analysis
    xml_string = params[:xml]
    xml = Hash.from_xml(xml_string)
    wards = xml["Nbest"]["Sentence"]["Word"]
    
    boke_array = Array.new

    wards.each do |ward|
      next if ward["Label"].nil?
      label = ward["Label"]
      boke_temp = Array.new
      
      # 渡されたデータがボケかどうかDBから探す
      Plain.where_like_tsukkomi("boke_origin", label).each do |boke|
        boke_temp.push(boke)
      end

      if boke_temp.empty?
        Plain.where_like_tsukkomi("boke_basic", label).each do |boke|
          boke_temp.push(boke)
        end
      end

      if !boke_temp.empty? 
        boke_temp.each do |boke|
          boke_array.push(boke)
        end
      end
    end

    if !boke_array.empty? # -> ボケが見つかったからツッコミを返す
      boke_data = boke_array[0]
      render json: {
        tsukkomi: boke_data.tsukkomi_origin,
        voice: "#{boke_data.id.to_s}.wav",
        id: boke_data.id
      }
    else # ->　見つからなかった
      render json: {
        tsukkomi: "なんでやねん",
        voice: "999.wav",
        id: 999
      }
    end
  end

end
