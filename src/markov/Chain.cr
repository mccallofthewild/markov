require "json"
require "./TransitionTable.cr"

# Module `Markov` contains the means for creating Markov Chains and executing Markov Processes.
module Markov
  # A `Chain` is a vehicle for generating probable sequences of type `LinkType`
  class Chain(LinkType)
    include JSON::Serializable

    # Returns an ordered `Array(LinkType)` of all `LinkType` elements generated
    getter generated : Array(LinkType)

    # Returns the trained instance of `TransitionTable`
    getter transition_table : TransitionTable(LinkType)

    # Returns `seed` element.
    getter seed : LinkType

    @generated : Array(LinkType) = Array(LinkType).new

    @custom_dead_end_handler = false

    @dead_end_handler : Proc(TransitionTable(LinkType), Chain(LinkType), Exception, LinkType)

    @seed : LinkType

    # For larger processes, you'll want to externally train a `TransitionTable` then
    # pass it in as an argument.
    # If `seed` is not provided, it will default to a random item chosen with `TransitionTable#random_key`
    def initialize(
      @transition_table : TransitionTable(LinkType),
      seed : LinkType | Nil = nil
    )
      if @transition_table.empty?
        raise Markov::Exceptions::EmptyTransitionTableException.new(
          method: "#new",
          message: "Add elements to your `TransitionTable` or try another constructor"
        )
      end
      if seed
        @seed = seed
      else
        @seed = @transition_table.random_key
      end
      validate_seed seed: @seed, rule: "`seed` must be an existing key in provided `transition_table`!"
      @dead_end_handler = default_dead_end_handler
    end

    # Makes it possible to use `#to_json` and `#from_json` (see Crystal docs)
    def initialize(pull : JSON::PullParser)
      @transition_table = TransitionTable(LinkType).new
      @seed = @transition_table.first_key
      @dead_end_handler = default_dead_end_handler

      hash = self
      pull.read_object do |key|
        if pull.kind == :null
          pull.read_next
        else
          hash[key] = TransitionMatrix(typeof(key)).new(pull) # V is the value type, as in `Hash(K, V)`
        end
      end
      hash
    end

    #
    # If you have a small (`Array`-sized) data set, you can pass it as `sample`
    # and a `TransitionTable` will be constructed for you with the sample data.
    #
    # `seed` should be the element in `sample` which you would like to begin the sequence.
    # If no `seed` is provided, a random element will be selected from `sample`.
    def initialize(
      sample : Array(LinkType),
      @seed : LinkType = sample.sample(1).first
    )
      @transition_table = TransitionTable(LinkType).new
      @transition_table.fill sample
      validate_seed seed: @seed, rule: "`seed` must be an existing item in `sample`!"
      @dead_end_handler = default_dead_end_handler
    end

    # Validates provided `seed` for initializers
    private def validate_seed(seed : LinkType | Nil, rule : String) : Bool
      if seed && @transition_table[seed]?
        return true
      else
        raise Exceptions::InvalidSeedException.new message: rule
        return false
      end
    end

    # Creates a default `Proc` for dead end `Exception` handlers.
    private def default_dead_end_handler
      Proc(TransitionTable(LinkType), Chain(LinkType), Exception, LinkType).new { |_| return @transition_table.first_key }
    end

    # Generates a probable, sequential `Array` of `LinkType` elements of `count` length
    def generate(count : Int32)
      i = 0
      temp_generated = [] of LinkType

      while i < count
        el = self.next
        temp_generated.push(el)
        i = i + 1
      end
      @generated.concat(temp_generated)

      temp_generated
    end

    # Sets an exception handler for `EmptyTransitionMatrixException` when `Chain` instance reaches a dead end
    # while using `Chain#generate` or `Chain#next`. Returned value is inserted as the next probable element.
    #
    # Usage:
    #
    # ```
    # c = Markov::Chain(String).new sample: ["Koala", "Kangaroo"] of String, seed: "Kangaroo"
    # c.on_dead_end do |transition_table, chain, exception|
    #   "Koala"
    # end
    # c.next # => "Koala"
    # c.next # => "Kangaroo"
    # c.next # => "Koala"
    # ```
    def on_dead_end(&block : Proc(TransitionTable(LinkType), Chain(LinkType), Exception, LinkType)) : Proc(TransitionTable(LinkType), Chain(LinkType), Exception, LinkType)
      @dead_end_handler = block
      @custom_dead_end_handler = true
      block
    end

    # Generates the next probable `LinkType` element
    def next : LinkType
      seed = @seed
      begin
        seed = @transition_table.probable after: @seed
      rescue ex : Markov::Exceptions::EmptyTransitionMatrixException
        if @custom_dead_end_handler
          seed = @dead_end_handler.call(@transition_table, self, ex)
        else
          raise ex
        end
      end
      validate_seed seed: seed, rule: "`@seed` must be an existing key in `@transition_table`"
      @seed = seed
      @generated.push(@seed)
      @seed
    end
  end
end
