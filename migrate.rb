require 'sequel'

SQLITE_DB = Sequel.sqlite('league.db')
PGSQL_DB = Sequel.connect('postgres://user:password@localhost/stats')

posts = SQLITE_DB["24174733".intern]

posts.each do |post|
	puts post[:id]
end



# c = DB[playerid]
# if !c.first(:champion => game.champion, :outcome => game.outcome, :kills => game.kills, :deaths => game.deaths, :assists => game.assists)
	
# 	c.insert(:champion => game.champion, :champion => game.champion, :outcome => game.outcome, :length => game.length,
# 		:kills => game.kills, :deaths => game.deaths, :assists => game.assists, :gold => game.gold, :minions => game.minions,
# 		:experience => game.experience)

# 	game.print
# end

playerids = {'IWANTHOTDOG' => '24174733', 'Sealiest Seal' => '41229298'}

playerids.each do |playername, playerid|
	#doc = Nokogiri::HTML(open('http://www.elophant.com/league-of-legends/summoner/na/' + playerid + '/recent-games'))

	playerid = playerid.intern

	posts = SQLITE_DB[playerid]
	posts.each do |post|
		puts post
		puts '\n'
	end

end