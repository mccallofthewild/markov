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

    it "raises `InvalidSeedException` with `sample` and invalid `seed`" do
      sample = ["Hippo", "Giraffe"]
      ex_raised = false
      begin
        c = Markov::Chain(String).new sample: sample, seed: "Monkey"
      rescue Markov::Exceptions::InvalidSeedException
        ex_raised = true
      end
      ex_raised.should eq true
    end

    it "initializes with `@transition_table` and `seed`" do
      tt = Markov::TransitionTable(String).new
      tt.fill table_with: ["Hippo", "Giraffe"]
      c = Markov::Chain(String).new transition_table: tt, seed: "Hippo"
    end

    it "initializes with `@transition_table` and no `seed`" do
      tt = Markov::TransitionTable(String).new
      tt.fill table_with: ["Hippo", "Giraffe"]
      c = Markov::Chain(String).new transition_table: tt
    end

    it "raises `InvalidSeedException` with `@transition_table` and invalid `seed`" do
      tt = Markov::TransitionTable(String).new
      tt.fill table_with: ["Hippo", "Giraffe"]
      ex_raised = false
      begin
        c = Markov::Chain(String).new transition_table: tt, seed: "Monkey"
      rescue Markov::Exceptions::InvalidSeedException
        ex_raised = true
      end
      ex_raised.should eq true
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

  it "#next" do  
    c = Markov::Chain(String).new sample: ["Koala", "Kangaroo"] of String, seed: "Koala"
    c.next().should eq "Kangaroo"
  end

  it "#on_dead_end" do
    c = Markov::Chain(String).new sample: ["Koala", "Kangaroo"] of String, seed: "Kangaroo"
    c.on_dead_end do |transition_table, chain, exception|
      "Koala"
    end
    c.next().should eq("Koala")
    c.next().should eq("Kangaroo")
    c.next().should eq("Koala")    
  end
  
end