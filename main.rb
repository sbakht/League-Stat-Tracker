require 'sinatra'
require 'sequel'
require_relative 'updateStats'


production = true
if production
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://league.db')
else 
	require 'sinatra/reloader'
	DB = Sequel.connect('sqlite://league.db')
end

get '/' do
	updateStats
	posts = DB["24174733".intern]
	@post = posts.all
	erb :main
end
get '/graphtest' do
	erb :graphtest
end

get '/:playerid' do
	@playerid = params[:playerid]
	@playerStats = DB[params[:playerid].intern]
	#@playerStats = @playerStats.select(:outcome).where(:champion => 'Twitch').all
	#@playerStats = @playerStats.all
	erb :playerpage
end


helpers do  
    include Rack::Utils  
    alias_method :h, :escape_html  
end

Thread.new do # trivial example work thread
  while true do
  	sleep 3600
    updateStats
  end
end

post '/plswork' do
	require 'json'
	# champions = params[:champion].chomp(' ').chomp(',')
	champions = params[:champion].split(/\s*,\s*/) #turn into array by splitting on spaces and commas
	if params[:champion] == "All" || params[:champion] == ""
		return DB[params[:playerid].intern].all.to_json
	end
	return DB[params[:playerid].intern].where(:champion => champions).all.to_json
end
