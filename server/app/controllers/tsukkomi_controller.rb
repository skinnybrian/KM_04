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
    xml_string = params[:xml]
    xml = Hash.from_xml(xml_string)
    wards = xml["Nbest"]["Sentence"]["Word"]
    
    boke = Array.new

    wards.each do |ward|
      next if ward["Label"].nil?
      label = ward["Label"]
      boke_temp = Array.new
      
      # 渡されたデータがボケかどうかDBから探す
      Plain.where_like_tsukkomi("boke_origin", label).each do |boke|
        boke_temp.push({label: label, tsukkomi: boke})
      end

      if boke_temp.empty?
        Plain.where_like_tsukkomi("boke_basic", label).each do |boke|
          boke_temp.push({label: label, tsukkomi: boke})
        end
      end
    end



    render json: boke.push(boke_temp)
  end

end
