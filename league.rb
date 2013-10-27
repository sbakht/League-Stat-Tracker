require 'nokogiri'
require 'open-uri'
require 'data_mapper'

class Game

	attr_accessor :champion, :outcome, :length, :kills, :assists, :deaths

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

end

# Get a Nokogiri::HTML::Document for the page we’re interested in...

doc = Nokogiri::HTML(open('http://www.elophant.com/league-of-legends/summoner/na/24174733/recent-games'))

# Do funky things with it using Nokogiri::XML::Node methods...

championList = doc.css('.title')
championList.shift #shift to remove string that isn't champ name

gameStateData = doc.css('.game-info span').select{ |g| g.text != "0"}

killsList = doc.css('.kills span') #returns "X kills"
deathsList = doc.css('.deaths span')
assistsList = doc.css('.assists span')

scoresData = doc.css('.scores span')

box = doc.css('.box')

puts box.length
puts box[11].css('.kills span')

# scores = []
# (0..59).step(6) do |i|
# 	scores << [scoresData[i].text, scoresData[i+1].text, scoresData[i+2].text, scoresData[i+3].text, scoresData[i+4].text]
# end
10.times do |i|
# puts scores[i]
# puts box[i]
# puts "\n\n"
end

# gameState = []
# (0..19).step(2) do |i|
# 	gameState << [gameStateData[i].text, gameStateData[i+1].text] #[Win/Lose, Length]
# end	

# 10.times do |i|
# 	champion = championList[i].content
# 	outcome = gameState[i][0]
# 	length = gameState[i][1]

# 	kills = killsList[i].content[0] # returns just # of kills
# 	deaths = deathsList[i].content[0]
# 	assists = assistsList[i].content[0]


# 	game = Game.new(champion, outcome, length)
# 	game.KDA(kills, deaths, assists)

# end


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

