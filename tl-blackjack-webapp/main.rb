require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do

  def calculate_total(cards)
     arr = cards.map {|e| e[1]}

    total = 0
    arr.each do |value|
      if value == "A"
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end

  arr.select{|e| e == "A"}.count.times do
    if total > 21
      total -= 10
    end
  end
  total
  end

end


before do
@show_hit_or_stay_buttons = true
end


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


post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  if calculate_total(session[:player_cards]) > 21
    @error = "#{session[:username]} busts with: #{calculate_total(session[:player_cards])}. Dealer wins!"
    @show_hit_or_stay_buttons = false
  end

  erb :game
end


post '/game/player/stay' do
  @success = "You have chosen to stay."
  @show_hit_or_stay_buttons = false
  
  erb :game
end

