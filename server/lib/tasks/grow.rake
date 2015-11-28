require "rake"

namespace :grow do

  desc "文章からボケとツッコミを分別してDBに保存_origin"
  task :text_base_origin, ['filename'] => :environment do |task, args|
    
    file_path = "data/" + args.filename.to_s
    nm = Natto::MeCab.new

    File.open(file_path) do |file|
      # 田中：どうも～、おめでとうございま～す！\n\n  ~>  どうも～、おめでとうございま～す！
      texts = file.read.split("\n").reject(&:blank?).map { |n| n.gsub(/.*：/, "") }

      texts.each_with_index do |text, index|
        nm.parse(text) do |elm|
          Plain.where_like_tsukkomi("tsukkomi_origin", elm.surface).each do |tsukkomi|
            if tsukkomi.boke_origin.nil?
              puts text
              tsukkomi.boke_origin = text
              # tsukkomi.save
            else
              puts tsukkomi
              puts text
              # Plain.create(tsukkomi_origin: tsukkomi, boke_origin: text)
            end
          end
        end
      end
    end
  end

  desc "文章からボケとツッコミを分別してDBに保存_basic"
  task :text_base_basic, ['filename'] => :environment do |task, args|

    file_path = "data/" + args.filename.to_s
    nm = Natto::MeCab.new('-F %f[6] -E \n')

    File.open(file_path) do |file|
      # 田中：どうも～、おめでとうございま～す！\n\n  ~>  どうも～、おめでとうございま～す！
      texts = file.read.split("\n").reject(&:blank?).map { |n| n.gsub(/.*：/, "") }

      texts.each_with_index do |text, index|
        nm.parse(text) do |elm|
          Plain.where_like_tsukkomi("tsukkomi_origin", elm.surface).each do |tsukkomi|
            if tsukkomi.boke_basic.nil?
              tsukkomi.boke_basic = text
              tsukkomi.save
            else
              Plain.create(tsukkomi_basic: tsukkomi, boke_basic: text)
            end
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
