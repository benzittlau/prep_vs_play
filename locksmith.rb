require './lib/player.rb'
require './lib/game.rb'
require 'pry'

wins = {:larry => 0, :pete => 0, :tie => 0}

1000.times do |i|
  game = Game.new(:min_value => 1, :max_value => 5, :variable => :a, :clear_attempts_on_success => true)
  loosey_larry = Player.new(:game => game, :attempt_eagerness => 10, :prep_eagerness => 1)
  prudent_pete = Player.new(:game => game, :attempt_eagerness => 1, :prep_eagerness => 10)

  winner = nil

  100.times do |index|
    loosey_larry.take_turn
    prudent_pete.take_turn

    print "Turn: #{index} \t"
    print "Larry's Score: #{loosey_larry.score} (#{loosey_larry.action_name}) \t#{loosey_larry.probability_of_correct_guess}\t"
    print "Pete's Score: #{prudent_pete.score} (#{prudent_pete.action_name}) \t#{prudent_pete.probability_of_correct_guess}"
    print "\n"
  end

  if loosey_larry.successes == prudent_pete.successes
    winner = :tie
  elsif loosey_larry.successes > prudent_pete.successes
    winner = :larry
  else
    winner = :pete
  end

  wins[winner] += 1
end

puts wins
