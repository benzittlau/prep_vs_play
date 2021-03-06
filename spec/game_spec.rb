require './lib/game.rb'
require 'pry'

describe Game do
  context "with a one variable basic game" do
    before(:each) do
      @game = Game.new()
      @range = [1,2,3,4,5,6,7,8,9,10]
    end

    describe "#possible_values_for" do
      context "for the variable :a" do
        it "should return an array with the values 1 through 10" do
          expect(@game.possible_values_for(:a)).to eq @range
        end
      end
    end

    describe "#permutation_count" do
      it "should have 10 permutations" do
        expect(@game.permutation_count).to eq 10
      end
    end

    describe "#answer" do
      it "should have one variable" do
        expect(@game.answer.count).to eq 1
      end

      it "should have an answer in the valid range" do
        expect(@range).to include @game.answer[:a]
      end
    end

    describe "#guessed_correctly?" do
      context "with a valid answer" do
        before(:each) do
          @valid_answer = @game.answer
        end

        it "should return true" do
          expect(@game.guessed_correctly?(@valid_answer)).to be true
        end
      end

      context "with an invalid answer" do
        before(:each) do
          @invalid_answer = {:a => @range.delete_if{|v| v == @game.answer[:a]}.sample}
        end

        it "should return true" do
          expect(@game.guessed_correctly?(@invalid_answer)).to be false
        end
      end
    end

    describe "#reveal_new_fact" do
      context "without any prior knowledge" do
        before(:each) do
          @knowledge = {:a => []}
          @fact = @game.reveal_new_fact(@knowledge)
        end

        it "should return a fact about the one variable" do
          expect(@fact[:variable]).to eq :a
        end

        it "should not return the answer" do
          expect(@fact[:value]).to_not eq @game.answer[:a]
        end
      end

      context "with only one more unknown" do
        before(:each) do
          @values = @range.delete_if{|v| v == @game.answer[:a]}
          @popped_value = @values.pop
          @knowledge = {:a => @values}
          @new_fact = @game.reveal_new_fact(@knowledge)
        end

        it "should return the one remaining fact" do
          expect(@new_fact[:value]).to eq @popped_value
        end
      end

      context "with no more unknowns" do
        before(:each) do
          @values = @range.delete_if{|v| v == @game.answer[:a]}
          @knowledge = {:a => @values}
          @new_fact = @game.reveal_new_fact(@knowledge)
        end

        it "should return false" do
          expect(@new_fact).to be false
        end
      end
    end

    describe "#min_value" do
      it "should return 1" do
        expect(@game.min_value(:a)).to eq 1
      end
    end

    describe "#max_value" do
      it "should return 10" do
        expect(@game.min_value(:a)).to eq 10
      end
    end

    describe "#permutation_count_with_knowledge" do
      context "with no prior knowledge" do
        it "should return 10" do
          expect(@game.permutation_count_with_knowledge({:a => []}, [])).to eq 10
        end
      end
    end
  end
end
