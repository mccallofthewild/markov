require "./spec_helper"

describe "README" do
  puts "\n\n :::BEGIN README_SPEC CONSOLE OUTPUTS::: \n __________________________________________________________ \n\n"
  describe "Basic" do
    it "#generate" do
      example_string = "how much wood would a woodchuck chuck if a woodchuck could chuck wood"
      example_arr = example_string.split(" ") # => ["how","much","wood","would","a","woodchuck","chuck","if","a","woodchuck","could","chuck","wood"]
      seed = example_arr[0]                   # => "how"
      example_chain = Markov::Chain(String).new sample: example_arr, seed: seed
      puts example_chain.generate(10) # => ["much", "wood", "would", "a", "woodchuck", "could", "chuck", "if", "a", "woodchuck"]

    end

    it "#next" do
      example_string = "how much wood would a woodchuck chuck if a woodchuck could chuck wood"
      example_arr = example_string.split(" ") # => ["how","much","wood","would","a","woodchuck","chuck","if","a","woodchuck","could","chuck","wood"]
      seed = example_arr[0]                   # => "how"
      example_chain = Markov::Chain(String).new sample: example_arr, seed: seed
      puts example_chain.next
      puts example_chain.next
      puts example_chain.next
    end
  end

  describe "Advanced" do
    it "#adds" do
      example_table = Markov::TransitionTable(String).new
      movie_one = %w(the great gatsby) # shortcut syntax for ["the","great","gatsby"]

      movie_one.each do |word|
        example_table.add(word)
      end
    end

    it "#fills" do
      example_table = Markov::TransitionTable(String).new
      movie_one = %w(the great gatsby)
      example_table.fill table_with: movie_one
    end

    it "#resets" do
      example_table = Markov::TransitionTable(String).new

      movie_one = %w(the great gatsby)
      example_table.fill table_with: movie_one

      example_table.reset
      movie_two = %w(great expectations)
      example_table.fill table_with: movie_two

      example_table.reset
      movie_three = %w(the great escape)
      example_table.fill table_with: movie_three

      example_table["gatsby"]["great"]?.should eq nil
    end

    it "Handling Dead Ends" do
      dead_end_array = %w(some say the world will end in fire)
      dead_end_chain = Markov::Chain(String).new sample: dead_end_array, seed: "fire"

      dead_end_chain.on_dead_end do |transition_table, chain, exception|
        "some"
      end

      dead_end_chain.next.should eq "some" # => "some"
      dead_end_chain.next.should eq "say"  # => "say"
      dead_end_chain.next.should eq "the"  # => "the"
    end
  end

  puts "\n\n __________________________________________________________ \n\n :::END README_SPEC CONSOLE OUTPUTS::: \n\n"
end
