require 'nokogiri'
require 'open-uri'
require "sequel"

class Game

	attr_reader :champion, :outcome, :length, :kills, :assists, :deaths, :gold, :minions, :experience

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
	
DB = Sequel.connect('sqlite://league.db')

def updateStats

	playerids = {'IWANTHOTDOG' => '24174733', 'Sealiest Seal' => '41229298'}

	playerids.each do |playername, playerid|
		doc = Nokogiri::HTML(open('http://www.elophant.com/league-of-legends/summoner/na/' + playerid + '/recent-games'))

		playerid = playerid.intern

		# connect to an in-memory database
		# DB = Sequel.sqlite

		# create an items table
		if !DB.table_exists? playerid
			DB.create_table playerid do
			  primary_key :id
			  String :champion
			  String :outcome
			  String :length
			  Integer :kills
			  Integer :deaths
			  Integer :assists
			  String :gold
			  Integer :minions
			  String :experience
			end
		end

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
		 	c = DB[playerid]
		 	if !c.first(:champion => game.champion, :outcome => game.outcome, :kills => game.kills, :deaths => game.deaths, :assists => game.assists)
			 	
			 	c.insert(:champion => game.champion, :champion => game.champion, :outcome => game.outcome, :length => game.length,
			 		:kills => game.kills, :deaths => game.deaths, :assists => game.assists, :gold => game.gold, :minions => game.minions,
			 		:experience => game.experience)

			 	game.print
			end

		end

		# posts = DB[playerid]
		# puts posts.all
	end
end