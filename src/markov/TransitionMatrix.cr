require "json"

module Markov
    
  # A `TransitionMatrix` is an object for storing and selecting transitions in a `Markov::Chain`.
  #
  # See [https://en.wikipedia.org/wiki/Stochastic_matrix](https://en.wikipedia.org/wiki/Stochastic_matrix)
  class TransitionMatrix(LinkType) < Hash(LinkType, Int32)

    # { ELEMENT => OCCURRENCE_COUNT }

    def initialize
      super
    end

    # Makes it possible to use `#to_json` and `#from_json` (see Crystal docs)
    def initialize(pull : JSON::PullParser)
      super()
      hash = self
      pull.read_object do |key|
        if pull.kind == :null
          pull.read_next
        else
          hash[key] = V.new(pull) # V is the value type, as in `Hash(K, V)`
        end
      end
      hash
    end

    # Adds item to `TransitionMatrix`
    def add(link : LinkType)
      count : Int32
      if self.has_key? link
        count = self[link] + 1
      else
        count = 1.to_i32
      end
      self[link] = count
    end

    # Returns decimal probability of each transition in the matrix
    def probabilities : Hash(LinkType, Float32)
      probs = Hash(LinkType, Float32).new(default_value: 0.to_f32)
      total : Int32 = sum()
      self.each do |key, value|
        probs[key] = value.to_f32 / sum.to_f32
      end
      probs
    end

    # Returns sum of all values (occurrences) in the matrix
    def sum : Int32
      total : Int32 = 0.to_i32
      self.each_value do |num|
        total = total + num
      end
      total
    end

    # Chooses a random, probable transition from the transitions in the matrix.
    # If matrix is empty, will throw `Markov::Exceptions::EmptyTransitionMatrixException`
    def probable_transition : LinkType

      err = Markov::Exceptions::EmptyTransitionMatrixException.new(
        method: "probable_transition",
        message: "No transitions availiable!"
      )

      if self.size === 0
        raise err
      end

      probable = nil
      
      success_params = {} of LinkType => Range(Int32, Int32)
      low : Int32 = 0
      high : Int32 = 0

      initial_low = low
      
      self.each do |key, count|
        low = high
        high = low + count
        # exclusive range (high not included)
        success_params[key] = low...high
      end


      final_high = high
      exclusive_capturing_range = initial_low...final_high
      random_selection : Int32 = Random.rand(exclusive_capturing_range)

      success_params.each do |key, capturing_range|
        if capturing_range.includes? random_selection
          probable = key
        end
      end

      if ! probable
        raise err
      else
        return probable
      end
    end

  end
  
end