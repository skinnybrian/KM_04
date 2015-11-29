namespace :voice do
  desc "docomoのAPIから音声ファイルを取得"
  task :get_voice => :environment do |task, args|
    api_key = Settings.voice_text.api_key
    file_name = "voice_text.wav"
    file_path = Settings.voice_text.file_path + file_name

    voice = TextToVoice.new(api_key)

    voice.speak("なんでやねん2")
    voice.save_as(file_path)
  end
end