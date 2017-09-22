require "./spec_helper"


describe Markov::TransitionTable do

  it "initializes" do
    typeof(Markov::TransitionTable(String).new).should eq(Markov::TransitionTable(String))
  end 

  it "#add" do
    tt = Markov::TransitionTable(String).new
    tt.add("string")
    typeof(tt["string"]).should eq(Markov::TransitionMatrix(String))
  end

  it "#fill" do
    string_array = %w(some say the world will end in fire)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: string_array

    has_all_elements_as_keys = true
    string_array.each do |s|
      if ! tt.has_key? s 
        has_all_elements_as_keys = false
        break
      end
    end
    has_all_elements_as_keys.should eq(true)
  end

  it "#random" do
    string_array = %w(some say the world will end in fire)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: string_array
    rnd = tt.random_matrix
    is_transition_matrix = typeof(rnd) == Markov::TransitionMatrix(String)
    is_transition_matrix.should eq(true)
  end

  it "#probable" do 
    string_array = %w(some say the world will end in fire)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: string_array

    typeof( tt.probable after: "some" ).should eq(String)
  end

end