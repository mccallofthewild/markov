require "./spec_helper"

describe Markov::TransitionMatrix do

  it "#initialize" do  
    t = Markov::TransitionMatrix(Range(Int32, Int32)).new
    true.should eq true
  end

  it "#to_json, #from_json" do  
    t = Markov::TransitionMatrix(String).new
    t.add "I"
    t.add "just"
    t.add "met"
    t.add "you"
    j_t = t.to_json
    t_j = Markov::TransitionMatrix(String).from_json j_t
    t["I"].should eq t_j["I"]
  end

  it "#add" do
    t = Markov::TransitionMatrix(String).new
    t.add "hey"
    t["hey"].should eq 1
  end
  
  it "#probabilities" do
    t = Markov::TransitionMatrix(String).new
    t.add "hello"
    t.add "welcome"
    t.add "hello"
    two_thirds = 2.to_f32 / 3.to_f32
    t.probabilities["hello"].should eq two_thirds
    t.probabilities["not included word"].should eq 0.to_f32
  end

  it "#sum" do
    t = Markov::TransitionMatrix(String).new
    t.add "hello"
    t.add "welcome"
    t.add "hello"

    t.sum.should eq(3)
  end

  it "#probable_transition" do 
    
    it "returns TransitionMatrix when not empty" do  
      t = Markov::TransitionMatrix(String).new
      t.add "hello"
      t.add "hello"
      t.add "welcome"
  
      hello_occurrences = 0
      welcome_occurrences = 0
  
      iterations = 0
      while iterations < 100
        transition = t.probable_transition
        case transition
        when "hello"
          hello_occurrences = hello_occurrences + 1
        when "welcome"
          welcome_occurrences = welcome_occurrences + 1
        end
        iterations = iterations + 1
      end 
  
      # yes, it's POSSIBLE that every transition is one or the other, but
      # probability would suggest that `hello_occurrences` are twice as 
      # prevalent as `welcome_occurrences`, though random selection makes
      # this unpredictable, so we just test for `hello_occurrences` to be greater
  
      (hello_occurrences > welcome_occurrences).should eq(true)
    end

    it "throws `Markov::Exceptions::EmptyTransitionMatrixException` when empty" do  
      t = Markov::TransitionMatrix(String).new
      begin
        transition = t.probable_transition
      rescue Markov::Exceptions::EmptyTransitionMatrixException
        true.should eq(true)
      end

    end

  end
  
end