class Plain < ActiveRecord::Base
  scope :where_like_tsukkomi, ->(search_for_colum, src_text) {
    text = src_text.gsub(/[\\%_]/){|m| "\\#{m}"}
    where("#{search_for_colum} LIKE ?", "%#{text}%") 
  }

end
