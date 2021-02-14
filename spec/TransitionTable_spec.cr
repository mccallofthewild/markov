require "./spec_helper"

describe Markov::TransitionTable do
  it "initializes" do
    typeof(Markov::TransitionTable(String).new).should eq(Markov::TransitionTable(String))
  end

  it "#add" do
    tt = Markov::TransitionTable(String).new
    tt.add("string")
    tt["string"] = tt["string"]
    typeof(tt["string"]).should eq(Markov::TransitionMatrix(String))
  end

  it "#fill" do
    string_array = %w(some say the world will end in fire)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: string_array

    has_all_elements_as_keys = true
    string_array.each do |s|
      if !tt.has_key? s
        has_all_elements_as_keys = false
        break
      end
    end
    has_all_elements_as_keys.should eq(true)
  end

  it "#probable" do
    string_array = %w(some say the world will end in fire)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: string_array

    typeof(tt.probable after: "some").should eq(String)
  end

  it "#probable?" do
    string_array = %w(some say the world will end in fire)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: string_array

    (tt.probable? after: "fire").should eq(nil)
  end

  it "#random_key" do
    string_array = %w(some say the world will end in fire)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: string_array
    rnd = tt.random_key
    is_string = typeof(rnd) == String
    is_string.should eq(true)
  end

  it "#random_matrix" do
    string_array = %w(some say the world will end in fire)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: string_array
    rnd = tt.random_matrix
    is_transition_matrix = typeof(rnd) == Markov::TransitionMatrix(String)
    is_transition_matrix.should eq(true)
  end

  it "#to_json, #from_json with strings" do
    string_array = %w(some say the world will end in fire)
    normal_init_table = Markov::TransitionTable(String).new
    normal_init_table.fill string_array

    normal_init_table_json = normal_init_table.to_json
    from_json_init_table = Markov::TransitionTable(String).from_json normal_init_table_json
    from_json_init_table["some"].should eq normal_init_table["some"]
  end

  it "#to_json, #from_json with integers" do
    int_array = [0, 1, 2, 3, 4, 5]
    normal_init_table = Markov::TransitionTable(Int32).new
    normal_init_table.fill int_array

    normal_init_table_json = normal_init_table.to_json
    from_json_init_table = Markov::TransitionTable(Int32).from_json normal_init_table_json
    from_json_init_table[1].should eq normal_init_table[1]
  end

  it "#reset" do
    movie_one = %w(the great gatsby)
    movie_two = %w(great expectations)
    tt = Markov::TransitionTable(String).new
    tt.fill table_with: movie_one
    tt.reset
    tt.fill table_with: movie_two

    (tt.probable? after: "gatsby").should eq nil
  end
end
