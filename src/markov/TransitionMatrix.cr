
module Markov
    
  # A `TransitionMatrix` is an object for storing and selecting transitions in a `Markov::Chain`.
  #
  # See [https://en.wikipedia.org/wiki/Stochastic_matrix](https://en.wikipedia.org/wiki/Stochastic_matrix)
  class TransitionMatrix(LinkType) < Hash(LinkType, Int32)

    # { ELEMENT => OCCURRENCE_COUNT }

    def initialize
      super
    end

    # Adds 
    def add(link : LinkType)
      count : Int32
      if self.has_key? link
        count = self[link] + 1
      else
        count = 1.to_i32
      end
      self[link] = count
    end

    def probabilities : Hash(LinkType, Float32)
      probs = Hash(LinkType, Float32).new(default_value: 0.to_f32)
      total : Int32 = sum
      self.each do |key, value|
        probs[key] = value.to_f32 / sum.to_f32
      end
      probs
    end

    # if array is empty, will throw IndexError
    def probable_transition : LinkType
      probable_array = [] of LinkType 

      self.each do |key, count|
        i = 0
        while i < count
          probable_array.push(key)
          i = i + 1
        end
      end

      begin
        return probable_array.sample(1).first
      rescue IndexError
        raise Markov::Exceptions::EmptyTransitionMatrixException.new(
          method: "probable_transition",
          message: "No transitions availiable!"
        )
      end
    end

    def sum : Int32
      total : Int32 = 0.to_i32
      self.each_value do |num|
        total = total + num
      end
      total
    end

  end
  
end