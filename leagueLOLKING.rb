require 'nokogiri'
require 'open-uri'
require 'data_mapper'

class Game

	attr_accessor :champion, :result

	def initialize
	end

	def KDA(kills,deaths,assists)
		@kills = kills
		@deaths = deaths
		@assists = assists
	end

	def returnKDA
		print @kills + " kills " + @deaths + " deaths " + @assists +  " assists\n"
	end




end

# Get a Nokogiri::HTML::Document for the page we’re interested in...

doc = Nokogiri::HTML(open('http://www.elophant.com/league-of-legends/summoner/na/24174733/recent-games'))

# Do funky things with it using Nokogiri::XML::Node methods...

championList = doc.css('.title')
championList.shift #shift to remove string that isn't champ name

data = doc.css('.game-info')

killsList = doc.css('.kills span') #returns "X kills"
deathsList = doc.css('.deaths span')
assistsList = doc.css('.assists span')


10.times do |i|
	name = championList[i].content
	kills = killsList[i].content[0] # returns just # of kills
	deaths = deathsList[i].content[0]
	assists = assistsList[i].content[0]
	game = Game.new
	game.champion = name
	#puts game.champion
	puts data[i].content 
	game.KDA(kills, deaths, assists)
	#game.returnKDA
end


DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/league.db")

class LeagueDB
	include DataMapper::Resource
	property :id, Serial
	property :champion, Text, :required => false
	property :kills, Integer
	property :deaths, Integer
	property :assists, Integer
end

DataMapper.finalize.auto_upgrade!

c = LeagueDB.new
c.champion = "Lux"
c.kills =  4
c.save

