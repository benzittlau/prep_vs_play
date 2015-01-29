require './lib/player.rb'
require './lib/game.rb'
require 'pry'


turns = {:larry => 0, :pete => 0}
wins = {:larry => 0, :pete => 0, :tie => 0}

1000.times do |i|
  score = {:larry => 0, :pete => 0}

  100.times do |index|
    game = Game.new(:min_value => 1, :max_value => 5, :variables => [:a, :b], :attempt_cost => 20, :cost_of_failure => 100, :reward_of_success => 500)
    loosey_larry = Player.new(:game => game, :attempt_eagerness => 10, :prep_eagerness => 1)
    prudent_pete = Player.new(:game => game, :attempt_eagerness => 1, :prep_eagerness => 10)

    turn_count = 0
    while loosey_larry.attempt_count == 0
      turn_count += 1
      loosey_larry.take_turn
    end

    score[:larry] += loosey_larry.score
    turns[:larry] += turn_count

    turn_count = 0
    while prudent_pete.attempt_count == 0
      turn_count += 1
      prudent_pete.take_turn
    end
    
    score[:pete] += prudent_pete.score
    turns[:pete] += turn_count
  end

  if score[:pete] == score[:larry]
    winner = :tie
  elsif score[:larry] > score[:pete]
    winner = :larry
  else
    winner = :pete
  end

  wins[winner] += 1
  print "."
end

puts wins
puts turns
