require './lib/player.rb'
require './lib/game.rb'
require 'pry'

describe Player do
  context "with a one variable basic game" do
    before(:each) do
      @game = Game.new()
      @range = [1,2,3,4,5,6,7,8,9,10]
      @player = Player.new(:game => @game)
    end

    describe "#initialize_knowledge" do
      it "should have create one variable of knowledge" do
        expect(@player.variable_knowledge.count).to eq 1
      end

      it "should initially be empty" do
        expect(@player.variable_knowledge[:a]).to be_empty
      end
    end

    describe "#probability_of_correct_guess" do
      context "in its initial basic state" do
        it "should be 1/10" do
          expect(@player.probability_of_correct_guess).to eq 0.1
        end
      end
    end

    describe "#variable_guesses_for_attempt" do
      before(:each) do
        @guess = @player.variable_guesses_for_attempt
      end

      it "should have one variable named a" do
        expect(@guess.keys).to eq [:a]
      end

      it "should have a value in the correct range" do
        expect(@range).to include @guess[:a]
      end
    end
  end
end
