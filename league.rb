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

	def print
		puts @champion + " " +  @outcome + " " + @length
	end

end

# Get a Nokogiri::HTML::Document for the page we’re interested in...

doc = Nokogiri::HTML(open('http://www.elophant.com/league-of-legends/summoner/na/24174733/recent-games'))

# Do funky things with it using Nokogiri::XML::Node methods...

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/league.db")

class LeagueDB
	include DataMapper::Resource
	property :id, Serial
	property :champion, String, :required => true
	property :outcome, String
	property :length, String
	property :kills, Integer
	property :deaths, Integer
	property :assists, Integer
	property :gold, String
	property :minions, Integer
	property :experience, String

end

DataMapper.finalize.auto_upgrade!


gameData = doc.css('.box')

10.times do |i|
 	champion = gameData[i+2].css('.title').text
 	outcome = gameData[i+2].css('.game-info span').select{ |g| g.text.include?("Match")  }[0].text
 	length = gameData[i+2].css('.game-info span').select{ |g| g.text.include?(":")  }[0].text

 	kills = gameData[i+2].css('.kills span').text.match(/\d+/)[0].to_i # returns just # of kills
 	deaths = gameData[i+2].css('.deaths span').text.match(/\d+/)[0].to_i
 	assists = gameData[i+2].css('.assists span').text.match(/\d+/)[0].to_i

 	scores = gameData[i+2].css('.scores span').first(3) #Gold, Minions, Experience
 	gold = scores[0].text
 	minions = scores[1].text
 	experience = scores[2].text


 	game = Game.new(champion, outcome, length)
 	game.KDA(kills, deaths, assists)
 	game.score(gold, minions, experience)

 	#Checks if a game with these stats already exist, assuming that it is the same game when all these stats are the same
 	if !LeagueDB.first(:champion => game.champion, :outcome => game.outcome, :kills => game.kills, :deaths => game.deaths, :assists => game.assists)
	 	c = LeagueDB.new 
	 	c.champion = game.champion
	 	c.outcome = game.outcome
	 	c.length = game.length
	 	c.kills = game.kills
	 	c.deaths = game.deaths
	 	c.assists = game.assists
	 	c.gold = game.gold
	 	c.minions = game.minions
	 	c.experience = game.experience
	 	c.save

	 	game.print
	end

end