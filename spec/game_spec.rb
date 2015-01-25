require './lib/game.rb'

describe Game do
  context "with a one variable basic game" do
    before(:each) do
      @game = Game.new()
    end

    describe "#possible_values_for" do
      context "for the variable :a" do
        it "should return an array with the values 1 through 10" do
          expect(@game.possible_values_for(:a))
        end
      end
    end

    describe "#permutation_count" do
      it "should have 10 permutations" do
        expect(@game.permutation.count).to eq 10
      end
    end
  end
end
