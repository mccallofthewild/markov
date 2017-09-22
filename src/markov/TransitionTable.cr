require "./TransitionMatrix.cr"

module Markov
  
  # A `TransitionTable` represents a mapping of keys to `TransitionMatrix`'s.
  class TransitionTable(LinkType) < Hash(LinkType, TransitionMatrix(LinkType))
    
    @last_added_key : LinkType | Nil

    def initialize 
      super
    end

    # Sequentially fills `TransitionTable` with values in given `Array` using `#add` method
    # Just a shortcut for looping through array and `#add`ing elements
    def fill( table_with sample : Array(LinkType) )
      sample.each do |key|
        add(key)
      end
    end

    # Inserts `key` into last added `key`'s `TransitionMatrix`, if applicable, 
    # and creates new `TransitionMatrix` for `key` if not already there.
    def add(key : LinkType)
      if @last_added_key
        last_matrix = self[@last_added_key]
        last_matrix.add(key)
      end
      if ! self.has_key? key
        self[key] = TransitionMatrix(LinkType).new
      end
      @last_added_key = key
    end

    # returns probable transition from the `TransitionMatrix` associated with key provided
    def probable( after key : LinkType ) : LinkType
      self[key].probable_transition
    end

    # returns random key
    def random_key : LinkType
      self.keys.sample(1).first
    end

    # returns random `TransitionMatrix` from table
    def random_matrix : TransitionMatrix(LinkType)
      self[random_key]
    end

  end
  
end