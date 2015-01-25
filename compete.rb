require './lib/player.rb'
require './lib/game.rb'
require 'pry'

game = Game.new()
player = Player.new(:game => game)

30.times do |index|
  player.take_turn
  p player.current_state
end
