require 'rubygems'
require 'sinatra'
require 'pry'

#set :sessions, true

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'random'

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

  def card_image(card)
    suit = case card[0]
    when 'H' then 'hearts'
    when 'C' then 'clubs'
    when 'D' then 'diamonds'
    when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end
        
    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def win_or_lose(player_total, dealer_total)
    if player_total > dealer_total
      @success = "Congradulations, #{session[:username]} wins!"
    elsif player_total < dealer_total
      @error = "#{session[:username]} lost! Dealer has: #{dealer_total}, dealer wins!" 
    else
      @success = "It's a tie!"
    end
  end


end


before do
  @show_hit_or_stay_buttons = true
  @hide_card = true
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
  if params[:username].empty?
    @error = "Name is required"
    halt erb(:set_name)
  elsif params[:username].split.each do |value|
    if value.to_i != 0
      @error = "Please enter only alphabetical letters"
      halt erb(:set_name)
    end
  end
    
  end
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

  player_total = calculate_total(session[:player_cards])

  if player_total == 21
    @success = "Congradulations, #{session[:username]} hit blackjack!"
    @show_hit_or_stay_buttons = false
  elsif player_total > 21
    @error = "#{session[:username]} busts with: #{calculate_total(session[:player_cards])}. Dealer wins!"
    @show_hit_or_stay_buttons = false
    @hide_card = false
  end

  erb :game
end


post '/game/player/stay' do
  @success = "#{session[:username]} has chosen to stay."
  @show_hit_or_stay_buttons = false

  redirect '/game/dealer'
end


get '/game/dealer' do
  @show_hit_or_stay_buttons = false
  @hide_card = false

  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == 21
    @error = "Sorry, Dealer hit Blackjack!"
  elsif dealer_total > 21
    @success = "Dealer busted! #{session[:username]} wins!"
  elsif dealer_total >= 17
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end
    
  erb :game  
end


post '/game/dealer/hit' do
  @hide_card = false
  @show_hit_or_stay_buttons = false
  session[:dealer_cards] << session[:deck].pop

  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total > 21
    @success = "Dealer busted! #{session[:username]} wins!"
  elsif dealer_total >= 17
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end
  erb :game
end

get '/game/compare' do
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])
  @show_hit_or_stay_buttons = false
  @hide_card = false

  win_or_lose(player_total,dealer_total)

  erb :game
end
    



