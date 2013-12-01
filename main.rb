require 'sinatra'
require 'sequel'
require_relative 'updateStats'
require_relative 'myfunctions'


production = true
if production
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://league.db')
else 
	require 'sinatra/reloader'
	DB = Sequel.connect('sqlite://league.db')
end

NUM_DISPLAY_COURSES = 10

get '/' do
	erb :home
end
get '/league' do
	erb :graphtest
end

helpers do  
    include Rack::Utils  
    alias_method :h, :escape_html  
end

Thread.new do # trivial example work thread
  while true do
  	sleep 36000
    updateStats
    updateAndEmailDatabase(DB)
  end
end

post '/plswork' do
	require 'json'
	# champions = params[:champion].chomp(' ').chomp(',')
	playerid = idExists(params[:playerid]).to_s #changes from username to id
	champions = params[:champion].split(/\s*,\s*/) #turn into array by splitting on spaces and commas
	if params[:champion] == "All" || params[:champion] == ""
		return DB[playerid.intern].all.to_json
	end

	champions.map! do |champ| champ[0].upcase + champ[1..-1].downcase end
	return DB[playerid.intern].where(:champion => champions).all.to_json
end


########################################################### Coursera

get '/coursera' do
	if !DB.table_exists? :courses
		DB.create_table :courses do
			primary_key :id
			String :title
			String :link
			String :categories
		end
	end

	if !DB.table_exists? :emails
		DB.create_table :emails do
			primary_key :id
			String :email
		end
	end
	@courses = DB[:courses].reverse_order(:id).all #reverses order so latest courses at top
	@emails = DB[:emails].all
	erb :coursera
end

post '/coursera' do
	@courses = DB[:courses].reverse_order(:id).all
	@categorySelection = params[:category]
	@emails = DB[:emails].all
	erb :coursera
	# redirect '/'
end

get '/update' do
	updateAndEmailDatabase(DB)
end

get '/testemail' do
	emailUsers
	redirect '/coursera'
end

post '/emailSubmit' do
	if params[:newemail]
		e = DB[:emails]
		e.insert(:email => params[:newemail])
	end
	redirect '/coursera'
end
