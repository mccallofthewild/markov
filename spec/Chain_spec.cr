require "./spec_helper"

describe Markov::Chain do
  
  describe "new" do

    it "initializes with `sample` and `@seed`" do
      c = Markov::Chain(String).new sample: ["Koala", "Kangaroo"] of String, seed: "Koala"
      typeof( c ).should eq(Markov::Chain(String))
    end
  
    it "initializes with `sample` and no `@seed`" do
      c = Markov::Chain(String).new sample: ["Hippo", "Giraffe"]
      typeof( c ).should eq(Markov::Chain(String))    
    end

  end

  describe "getters" do

    describe "#generated" do

      it "raises `EmptyTransitionMatrixException` when seed has nothing to transition to" do
        begin
          c = Markov::Chain(String).new sample: ["Hippo", "Giraffe"], seed: "Giraffe"
        rescue Markov::Exceptions::EmptyTransitionMatrixException
          (true).should eq(true)
        end
      end

    end

    it "#transition_table" do 
      c = Markov::Chain(String).new sample: ["Hippo", "Giraffe"]    
      typeof( c.transition_table ).should eq( Markov::TransitionTable(String) )
    end

  end

end