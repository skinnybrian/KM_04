require "rake"

namespace :grow do

  desc "文章からボケとツッコミを分別してDBに保存_origin"
  task :text_base_origin, ['filename'] => :environment do |task, args|
    
    file_path = args.filename.to_s
    nm = Natto::MeCab.new

    File.open(file_path) do |file|
      # 田中：どうも～、おめでとうございま～す！\n\n  ~>  どうも～、おめでとうございま～す！
      texts = file.read.split("\n").reject(&:blank?).map { |n| n.gsub(/.*：/, "") }

      texts.each_with_index do |text, index|
        nm.parse(text) do |elm|
          Plain.where_like_tsukkomi("tsukkomi_origin", elm.surface).each do |tsukkomi|
            if tsukkomi.boke_origin.nil?
              tsukkomi.boke_origin = text
              tsukkomi.save
            else
              Plain.create(tsukkomi_origin: tsukkomi, boke_origin: text)
            end
          end
        end
      end
    end
  end

  desc "文章からボケとツッコミを分別してDBに保存_basic"
  task :text_base_basic, ['filename'] => :environment do |task, args|

    file_path = "db/" + args.filename.to_s
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
end
