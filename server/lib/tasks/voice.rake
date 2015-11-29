namespace :voice do

  def request_voice(file_path, speak_text)
    api_key = Settings.voice_text.api_key
    voice = TextToVoice.new(api_key)

    voice.speak(speak_text)
    voice.save_as(file_path)
  end

  desc "docomoのAPIから音声ファイルを取得"
  task :get_voice, ["file_name", "speak_text"] => :environment do |task, args|

    puts "start task"
    file_path = Settings.voice_text.file_path + args.file_name
    request_voice(file_path, args.speak_text)
    puts "file saved."
  end

  desc "get_voiceタスクをDBのツッコミの分だけ動かす"
  task :get_tsukkomi => :environment do |task, args|
    tsukkomis = Plain.all.select(:id, :tsukkomi_origin).limit(5)
    tsukkomis.each do |tsukkomi|
      puts tsukkomi.tsukkomi_origin
      file_path = Settings.voice_text.file_path + tsukkomi.id.to_s + ".wav"
      request_voice(file_path, tsukkomi.tsukkomi_origin)
    end
  end
end