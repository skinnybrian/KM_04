require "rake"

namespace :grow do

  def search_list(lists, elm)
    result = false
    lists.each do |obj|
      result = true if elm.match(/^#{obj}/)
    end

    return result
  end

  desc "文章からボケとツッコミを分別してDBに保存_ボケを増やしていく"
  task :text_base_boke, ['filename'] => :environment do |task, args|
    
    file_path = "data/" + args.filename.to_s
    nm_origin = Natto::MeCab.new
    nm_basic = Natto::MeCab.new('-F %f[6] -E \n')
    black_list = ["助詞", "助動詞", "係助詞", "副助詞", "記号", "BOS/EOS"]
    white_list = ["名詞,一般", "動詞"]

    File.open(file_path) do |file|
      # 田中：どうも～、おめでとうございま～す！\n\n  ~>  どうも～、おめでとうございま～す！
      texts = file.read.split("\n").reject(&:blank?).map { |n| n.gsub(/.*：/, "").gsub(/!|！|~|〜|\?|？/, "") }

      texts.each_with_index do |text, index|
        # puts("****************")
        # puts("元の文: #{text}")
        # puts("****************")
        # puts nm.parse(text)
        # puts("****************")

        nm_origin.parse(text) do |elm|

          # 形態素がブラックリストに含まれていたらskip
          # next if search_list(black_list, elm.feature) || elm.surface.length == 1

          # 形態素がホワイトリストに含まれていなかったらskip
          next if !search_list(white_list, elm.feature) || elm.surface.length < 2

          Plain.where_like_tsukkomi("tsukkomi_origin", elm.surface).each do |tsukkomi|
            
            boke_origin = texts[index-1]
            tsukkomi_origin = tsukkomi.tsukkomi_origin
            boke_basic = nm_basic.parse(boke_origin)
            tsukkomi_basic = nm_basic.parse(tsukkomi_origin)

            puts("形態素: \t#{elm.surface}")
            puts("ボケ_origin: \t#{boke_origin}")
            puts("ツッコミ_origin: \t#{tsukkomi_origin}")
            puts("ボケ_basic: \t#{boke_basic}")
            puts("ツッコミ_basic: \t#{tsukkomi_basic}")
            puts("*****************************************************")

            # Plain.create(
            #   boke_origin: boke_origin,
            #   tsukkomi_origin: tsukkomi_origin,
            #   boke_basic: boke_basic,
            #   tsukkomi_basic: tsukkomi_basic
            # )


          end
        end
      end
    end
  end

  desc "文章からボケとツッコミを分別してDBに保存_ツッコミを増やしていく"
  task :text_base_tsukkomi, ['filename'] => :environment do |task, args|
    
    file_path = "data/" + args.filename.to_s
    nm_origin = Natto::MeCab.new
    nm_basic = Natto::MeCab.new('-F %f[6] -E \n')
    white_list = ["名詞,一般", "動詞"]

    File.open(file_path) do |file|
      texts = file.read.split("\n").reject(&:blank?).map { |n| n.gsub(/.*：/, "").gsub(/!|！|~|〜|\?|？/, "") }

      texts.each_with_index do |text, index|
        nm_origin.parse(text) do |elm|

          # 形態素がホワイトリストに含まれていなかったらskip
          next if !search_list(white_list, elm.feature) || elm.surface.length < 2

          Plain.where_like_tsukkomi("boke_origin", elm.surface).each do |boke|
            tsukkomi_origin = texts[index+1] if texts.count > index
            boke_origin = boke.boke_origin
            boke_basic = nm_basic.parse(boke_origin)
            tsukkomi_basic = nm_basic.parse(tsukkomi_origin)

            puts("形態素: \t#{elm.surface}")
            puts("ボケ_origin: \t#{boke_origin}")
            puts("ツッコミ_origin: \t#{tsukkomi_origin}")
            puts("ボケ_basic: \t#{boke_basic}")
            puts("ツッコミ_basic: \t#{tsukkomi_basic}")
            puts("*****************************************************")

            # Plain.create(
            #   boke_origin: boke_origin,
            #   tsukkomi_origin: tsukkomi_origin,
            #   boke_basic: boke_basic,
            #   tsukkomi_basic: tsukkomi_basic
            # )


          end
        end
      end
    end
  end



  desc "音声ファイル(引数で指定)をgoogle speech APIでテキストに"
  task :voice_base, ['filename'] => :environment do |task, args|
    base_url = Settings.google_speech.base_url
    api_key = Settings.google_speech.api_key
    content_type = "audio/l16; rate=16000"
    lang = "ja"
    output = "json"
    file_path = Settings.google_speech.file_path + args.filename.to_s

    request_url = "#{base_url}?lang=#{lang}&output=#{output}&key=#{api_key}"

    uri = URI(request_url)
    https = Net::HTTP.new(uri.hostname, uri.port)
    https.use_ssl = true

    response = https.start do |h|
      req = Net::HTTP::Post.new(uri)
      req.body = File.read(file_path)
      req.content_type = content_type
      h.request(req)
    end

    result_data = response.body.force_encoding('UTF-8')
    result_data.split("\n").each do |res|
      data = JSON.parse(res)
      next if data["result"].empty?
      boke = data["result"][0]["alternative"][0]["transcript"]
      puts boke

    end
  end
end
