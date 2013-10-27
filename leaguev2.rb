require 'nokogiri'
require 'open-uri'
require 'data_mapper'

class Game

	attr_reader :champion, :outcome, :length, :kills, :assists, :deaths,
	:gold, :minions, :experience

	def initialize(champion, outcome, length)
		@champion = champion
		@outcome = outcome
		@length = length
	end

	def state
		return @outcome + " of " + @length  + " minutes long"
	end

	def KDA(kills,deaths,assists)
		@kills = kills
		@deaths = deaths
		@assists = assists
	end

	def returnKDA
		return @kills + " kills " + @deaths + " deaths " + @assists +  " assists\n"
	end

	def score(gold, minions, experience)
		@gold = gold
		@minions = minions
		@experience = experience
	end

end

# Get a Nokogiri::HTML::Document for the page we’re interested in...

doc = Nokogiri::HTML(open('http://www.elophant.com/league-of-legends/summoner/na/24174733/recent-games'))

# Do funky things with it using Nokogiri::XML::Node methods...


gameData = doc.css('.box')

10.times do |i|
 	champion = gameData[i+2].css('.title').text
 	outcome = gameData[i+2].css('.game-info span').select{ |g| g.text.include?("Match")  }[0].text
 	length = gameData[i+2].css('.game-info span').select{ |g| g.text.include?(":")  }[0].text

 	kills = gameData[i+2].css('.kills span').text.match(/\d+/) # returns just # of kills
 	deaths = gameData[i+2].css('.deaths span').text.match(/\d+/)
 	assists = gameData[i+2].css('.assists span').text.match(/\d+/)

 	scores = gameData[i+2].css('.scores span').first(3) #Gold, Minions, Experience
 	gold = scores[0].text
 	minions = scores[1].text
 	experience = scores[2].text


 	game = Game.new(champion, outcome, length)
 	game.KDA(kills, deaths, assists)
 	game.score(gold, minions, experience)
 	#puts game.returnKDA
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

