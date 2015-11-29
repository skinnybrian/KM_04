namespace :voice do
  desc "docomoのAPIから音声ファイルを取得"
  task :get_voice => :environment do |task, args|
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