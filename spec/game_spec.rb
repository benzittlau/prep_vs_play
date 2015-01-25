require './lib/game.rb'

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
  end
end
