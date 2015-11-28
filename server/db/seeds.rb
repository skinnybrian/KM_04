# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "csv"

nm = Natto::MeCab.new('-F %f[6] -E \n') 

CSV.foreach('db/seed/seed.csv') do |row|
#	puts("#{row[0]} : #{row[1]}")
	p = Plain.new
	if !row[0].nil?
		p.boke_origin = row[0]
		p.boke_basic = nm.parse(p.boke_origin)
	end
	p.tsukkomi_origin = row[1]
	p.tsukkomi_basic = nm.parse(p.tsukkomi_origin)
	
	p.save #DBに格納
	#puts("#{p.tsukkomi_origin}:#{p.tsukkomi_basic}")
end
