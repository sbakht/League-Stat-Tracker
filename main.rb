require 'sinatra'
require 'sinatra/reloader'
require 'sequel'
require_relative 'updateStats'

DB = Sequel.connect('sqlite://league.db')


get '/' do
	updateStats
	posts = DB["24174733".intern]
	@post = posts.all
	erb :main
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