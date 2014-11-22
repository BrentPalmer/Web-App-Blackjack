require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  if session[:username]
    redirect '/game'
  else
    redirect '/set_name'
  end
end

get '/set_name' do
  erb :set_name
end  

post '/set_name' do
  session[:username] = params[:username]
  redirect '/game'
end

get '/game' do

  suits = ["H", "C", "D", "S"]
  values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times do
    session[:dealer_cards] << session[:deck].pop
    session[:player_cards] << session[:deck].pop
  end



  erb :game
end

