require "./TransitionTable.cr"

# Module `Markov` contains all the means for creating Markov Chains and running Markov Processes.
module Markov
  
  # A `Chain` is a vehicle for generating probable sequences of type `LinkType`
  class Chain(LinkType)

    # Returns an ordered `Array(LinkType)` of all `LinkType` elements generated
    getter :generated
    
    # Returns the trained instance of `TransitionTable`
    getter :transition_table

    @generated : Array(LinkType) = Array(LinkType).new

    # For larger processes, you'll want to externally train a `TransitionTable` then 
    # pass it in as an argument.
    # If `seed` is not provided, it will default to a random item chosen with `TransitionTable#random_matrix`
    def initialize(
      @transition_table : TransitionTable(LinkType),
      @seed : LinkType
    )
      if @transition_table.is_empty?
        raise Markov::Exceptions::EmptyTransitionTableException.new(
          method: "#new", 
          message: "Add elements to your `TransitionTable` or try another constructor"
        )
      end
    end

    # 
    # If you have a small (`Array`-sized) data set, you can pass it as `sample`
    # and a `TransitionTable` will be constructed for you with the sample data. 
    #
    # `seed` should be the element in `sample` which you would like to begin the sequence.
    # If no `seed` is provided, a random element will be selected from `sample`.
    def initialize(
      sample : Array(LinkType),
      @seed : LinkType = sample.sample(1).first,
    )
      @transition_table = TransitionTable(LinkType).new
      @transition_table.fill sample
    end

    # Generates a probable, sequential `Array` of `LinkType` elements of `count` length
    def generate(count : Int32)
      i = 0
      temp_generated = [] of LinkType 

      while i<count
        el = self.next
        temp_generated.push(el)
        i = i+1
      end
      @generated.concat(temp_generated)

      temp_generated
    end

    # Generates the next probable `LinkType` element
    def next : LinkType
      @seed = @transition_table.probable after: @seed
      @generated.push(@seed)
      @seed
    end

  end
end